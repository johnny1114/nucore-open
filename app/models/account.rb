class Account < ActiveRecord::Base
  has_many   :account_users
  has_one    :owner, :class_name => 'AccountUser', :conditions => {:user_role => AccountUser::ACCOUNT_OWNER, :deleted_at => nil}
  has_many   :business_admins, :class_name => 'AccountUser', :conditions => {:user_role => AccountUser::ACCOUNT_ADMINISTRATOR, :deleted_at => nil}
  has_many   :price_group_members
  has_many   :order_details
  has_many   :statements, :through => :order_details
  belongs_to :facility
  accepts_nested_attributes_for :account_users

  scope :active, lambda {{ :conditions => ['expires_at > ? AND suspended_at IS NULL', Time.zone.now] }}
  scope :for_facility, lambda { |facility| { :conditions => ["type <> 'PurchaseOrderAccount' OR (type = 'PurchaseOrderAccount' AND facility_id = ?)", facility.id] }}

  validates_presence_of :account_number, :description, :expires_at, :created_by, :type
  validates_length_of :description, :maximum => 50

  validate do |acct|
    # an account owner if required
    unless acct.account_users.any?{ |au| au.user_role == AccountUser::ACCOUNT_OWNER }
      acct.errors.add(:base, "Must have an account owner")
    end
  end

  def type_string
    case self
      when PurchaseOrderAccount
        'Purchase Order'
      when CreditCardAccount
        'Credit Card'
      when NufsAccount
        'Chart String'
      else
        'Account'
    end
  end

  def <=>(obj)
    account_number <=> obj.account_number
  end

  def owner_user
    self.owner.user if owner
  end

  def business_admin_users
    self.business_admins.collect{|au| au.user}
  end

  def notify_users
    [owner_user] + business_admin_users
  end

  def suspend!
    self.suspended_at = Time.zone.now
    self.save
  end

  def unsuspend!
    self.suspended_at = nil
    self.save
  end

  def suspended?
    !self.suspended_at.blank?
  end

  def expired?
    expires_at && expires_at <= Time.zone.now
  end

  def account_pretty
    "#{description} (#{account_number})"
  end

  def validate_against_product(product, user)
    # does the facility accept payment method?
    return "#{product.facility.name} does not accept #{self.type_string} payment" unless product.facility.can_pay_with_account?(self)

    # does the product have a price policy for the user or account groups?
    return "The #{self.type_string} has insufficient price groups" unless product.can_purchase?((self.price_groups + user.price_groups).flatten.uniq.collect {|pg| pg.id})

    # check chart string account number
    if self.is_a?(NufsAccount)
      accts=product.is_a?(Bundle) ? product.products.collect(&:account) : [ product.account ]
      accts.uniq.each {|acct| return "The #{self.type_string} is not open for the required account" unless self.account_open?(acct) }
    end

    return nil
  end

  def self.need_statements (facility)
    # find details that are complete, not yet statemented, priced, and not in dispute
    details = OrderDetail.need_statement(facility)
    find(details.collect{ |detail| detail.account_id }.uniq || [])
  end

  def self.need_notification (facility)
    # find details that are complete, not yet notified, priced, and not in dispute
    details = OrderDetail.need_notification(facility)
    find(details.collect{ |detail| detail.account_id }.uniq || [])
  end

  def facility_balance (facility, date=Time.zone.now)
    details = facility.order_details.complete.find(:all, :conditions => ['order_details.fulfilled_at <= ? AND price_policy_id IS NOT NULL AND order_details.account_id = ?', date, id])
    details.collect{|od| od.total}.sum.to_f
  end

  # this will return the balance of orders that have been statemented or journaled (successfully) but not reconciled
  def unreconciled_total(facility)
    details=OrderDetail.account_unreconciled(facility, self)
    unreconciled_total=0

    details.each do |od|
      total=od.cost_estimated? ? od.estimated_total : od.actual_total
      unreconciled_total += total if total
    end

    unreconciled_total
  end

  def latest_facility_statement (facility)
    statements.latest(facility).first
  end

  def update_order_details_with_statement (statement)
    details=order_details.find(:all, :joins => :order, :readonly => false, :conditions => [
        'orders.facility_id = ? AND order_details.reviewed_at < ? AND order_details.statement_id IS NULL', statement.facility.id, Time.zone.now ]
    )
    details.each do |od|
      od.update_attributes({:reviewed_at => Time.zone.now+7.days, :statement => statement })
    end
  end

  def can_be_used_by?(user)
    !(account_users.find(:first, :conditions => ['user_id = ? AND deleted_at IS NULL', user.id]).nil?)
  end

  def is_active?
    expires_at > Time.zone.now && suspended_at.nil?
  end

  def to_s
    "#{description} (#{account_number})"
  end
  
  def price_groups
    (price_group_members.collect{ |pgm| pgm.price_group } + (owner_user ? owner_user.price_groups : [])).flatten.uniq
  end
end
