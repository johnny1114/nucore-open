class InstrumentsController < ProductsCommonController
  customer_tab  :show
  admin_tab     :agenda, :create, :edit, :index, :manage, :new, :schedule, :update
  
  before_filter :prepare_relay_params, :only => [ :create, :update ]

  # GET /instruments
  def index
    super
    # find current and next upcoming reservations for each instrument
    @reservations = {}
    @instruments.each { |i| @reservations[i.id] = i.reservations.upcoming[0..2]}
  end

  # GET /instruments/1
  def show
    raise ActiveRecord::RecordNotFound if !product_is_accessible?
    add_to_cart = true
    login_required = false
    
    # do the product have active price policies && schedule rules
    unless @instrument.can_purchase?
      add_to_cart = false
      flash[:notice] = t_model_error(Instrument, 'not_available', :instrument => @instrument)
    end

    # is user logged in?
    if add_to_cart && acting_user.nil?
      login_required = true
      add_to_cart = false
    end

    # is the user approved? or is the logged in user an operator of the facility (logged in user can override restrictions)
    
    if add_to_cart && !@instrument.is_approved_for?(acting_user)
      add_to_cart = false unless session_user and session_user.can_override_restrictions?(@instrument)
      flash[:notice] = t_model_error(Instrument, 'requires_approval_html', :instrument => @instrument, :facility => @instrument.facility, :email => @instrument.facility.email).html_safe
    end

    # does the product have any price policies for any of the groups the user is a member of?
    if add_to_cart && !(@instrument.can_purchase?((acting_user.price_groups + acting_user.account_price_groups).flatten.uniq.collect{ |pg| pg.id }))
      add_to_cart = false
      flash[:notice] = "You are not in a price group that may reserve instrument #{@instrument.to_s}; please contact the facility."
    end

    # when ordering on behalf of, does the staff have permissions for this facility?
    if add_to_cart && acting_as? && !session_user.operator_of?(@instrument.facility)
      add_to_cart = false
      flash[:notice] = 'You are not authorized to order instruments from this facility on behalf of a user.'
    end
    @add_to_cart = add_to_cart
    
    if login_required
      session[:requested_params]=request.fullpath
      return redirect_to new_user_session_path
    elsif !add_to_cart
      return redirect_to facility_path(current_facility)
    end

    redirect_to add_order_path(acting_user.cart(session_user, false), :product_id => @instrument.id, :quantity => 1)
  end

  # PUT /instruments/1
  def update
    @header_prefix = "Edit"

    Instrument.transaction do                
      if @instrument.update_attributes(params[:instrument])
        @instrument.relay.destroy if @instrument.relay && !params[:instrument].has_key?(:relay_attributes)
        flash[:notice] = 'Instrument was successfully updated.'
        return redirect_to(manage_facility_instrument_url(current_facility, @instrument))
      end
    end

    render :action => "edit"
  end

  # GET /instruments/1/schedule
  def schedule
    @admin_reservations = @instrument.reservations.find(:all, :conditions => ['reserve_end_at > ? AND order_detail_id IS NULL', Time.zone.now])
  end

  # GET /instruments/1/agenda
  def agenda
  end

  # GET /facilities/:facility_id/instruments/:instrument_id/status
  def instrument_status
    begin
      @relay  = @instrument.relay
      status = Rails.env.test? ? true : @relay.get_status_port(@relay.port)
      @status = @instrument.instrument_statuses.create!(:is_on => status)
    rescue
      raise ActiveRecord::RecordNotFound
    end
    render :layout => false
  end

  # GET /facilities/:facility_id/instruments/:instrument_id/switch
  def switch
    raise ActiveRecord::RecordNotFound unless params[:switch] && (params[:switch] == 'on' || params[:switch] == 'off')

    begin
      relay = @instrument.relay
      status=true

      unless Rails.env.test?
        port=@instrument.relay.port
        params[:switch] == 'on' ? relay.activate_port(port) : relay.deactivate_port(port)
        status = relay.get_status_port(port)
      end

      @status = @instrument.instrument_statuses.create!(:is_on => status)
    rescue
      raise ActiveRecord::RecordNotFound
    end
    render :action => :instrument_status, :layout => false
  end

  private

  def prepare_relay_params
    case params[:control_mechanism]
      when 'relay'
      when 'timer'
        params[:instrument][:relay_attributes].merge!(
            :ip => nil,
            :port => nil,
            :username => nil,
            :password => nil,
            :type => RelayDummy.name
        )
      else
        params[:instrument].delete(:relay_attributes)
    end
  end
end
