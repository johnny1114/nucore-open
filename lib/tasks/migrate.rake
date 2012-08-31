namespace :migrate do

  task :users, [:fake, :backtrace] => :environment do |t, args|
    @backtrace=args.backtrace
    @logger=Logger.new(File.open("#{Rails.root}/log/migration.log", 'w'))

    begin
      User.transaction do
        pid2uid, uname2usr={}, {}

        # Migrate users
        all_pers=Pers::Person.find(
          :all,
          :conditions => "t_security_logins.portal = 'nucore'",
          :joins => 'INNER JOIN t_security_logins ON t_security_logins.username = t_personnel.username'
        )

        all_pers.each do |per|
          usr=User.new(
            :email => per.email,
            :first_name => per.first_name,
            :last_name => per.last_name,
            :username => per.username
          )

          retried=false

          begin
            usr.save!
          rescue ActiveRecord::RecordInvalid
            raise if retried
            usr.email="user-#{per.personnel_id}@example.com"
            retried=true
            retry
          rescue => e
            log("Could not save Pers::Person #{per.username}, #{per.id}", e)
          else
            pid2uid[per.personnel_id]=usr.id
            uname2usr[usr.username]=usr
          end
        end

        assign_roles_and_permissions(uname2usr)
        update_foreign_keys(pid2uid)

        if args.fake
          log('Rolling back migration...')
          raise ActiveRecord::Rollback
        end
      end
    rescue => e
      log('Migration error', e)
    ensure
      @logger.close
    end
  end


  def log(msg, except=nil)
    if except
      msg += ": #{except.message}"
      msg += "\n#{except.backtrace.join("\n")}" if @backtrace
    end

    @logger.error(msg)
    puts msg
  end


  def assign_roles_and_permissions(name_to_user)
    all_operators=Pers::GroupMembership.find(
      :all,
      :conditions => { :portal => 'nucore' },
      :joins => 'INNER JOIN t_personnel ON t_security_group_members.username = t_personnel.username'
    )

    all_operators.each do |op|
      begin
        usr=name_to_user[op.username]
        raise "No user #{op.username} to grant permissions to! (GroupMembership #{op.id})" unless usr

        if op.group_name == UserRole::ADMINISTRATOR
          UserRole.grant(usr, UserRole::ADMINISTRATOR)
          next
        end

        affiliate_id=op.affiliate_id
        raise "User #{op.username} is a #{op.group_name} without facility! (GroupMembership #{op.id})" unless affiliate_id
        facility=Facility.find_by_pers_affiliate_id affiliate_id
        raise "Could not find facility with id #{affiliate_id}! (GroupMembership #{op.id})" unless facility

        case op.group_name
          when UserRole::FACILITY_DIRECTOR
            UserRole.grant(usr, UserRole::FACILITY_DIRECTOR, facility)
          when UserRole::FACILITY_ADMINISTRATOR
            UserRole.grant(usr, UserRole::FACILITY_ADMINISTRATOR, facility)
          when UserRole::FACILITY_STAFF
            UserRole.grant(usr, UserRole::FACILITY_STAFF, facility)
        end
      rescue => e
        log('Role/permission error', e)
      end
    end
  end


  def update_foreign_keys(personnel_to_user)
    cols2update=[ 'user_id', 'created_by', 'updated_by', 'deleted_by', 'approved_by', 'canceled_by', 'assigned_user_id' ]

    Dir["#{Rails.root}/app/models/*.rb"].each do |file_path|
      begin
        basename=File.basename(file_path, File.extname(file_path))
        clazz=basename.camelize.constantize
        next unless clazz.respond_to?(:column_names) && clazz.superclass == ActiveRecord::Base

        has_cols=clazz.column_names & cols2update
        next if has_cols.blank?

        clazz.all.each do |obj|
          has_cols.each do |col|
            personnel_id=obj[col.to_sym]

            if personnel_id.blank?
              log "Null value for #{col} on #{clazz.name} instance #{obj.id}. Next." if (col == 'created_by' || !col.end_with?('_by'))
              next
            end

            uid=personnel_to_user[personnel_id]

            if uid.blank?
              if clazz == ProductUser
                obj.destroy
                break
              elsif clazz != UserPriceGroupMember && clazz != UserRole
                log "No user id found for personnel_id #{personnel_id}! (#{clazz.name.tableize.singularize}##{col}). Next."
              end

              next
            end

            obj[col]=uid
            obj.save(false)
          end
        end
      rescue => e
        log('FK update error', e)
      end
    end
  end

end