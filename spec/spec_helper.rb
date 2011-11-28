require 'rubygems'
require 'spork'

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading
#   code that you don't normally modify during development in the
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
Spork.prefork do
  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'factory_girl'
  require 'shoulda'
  require 'mocha'

  # Uncomment the next line to use webrat's matchers
  #require 'webrat/integrations/rspec-rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true

    # == Fixtures
    #
    # You can declare fixtures for each example_group like this:
    #   describe "...." do
    #     fixtures :table_a, :table_b
    #
    # Alternatively, if you prefer to declare them only once, you can
    # do so right here. Just uncomment the next line and replace the fixture
    # names with your fixtures.
    #
    # config.global_fixtures = :table_a, :table_b
    #
    # If you declare global fixtures, be aware that they will be declared
    # for all of your examples, even those that don't use them.
    #
    # You can also declare which fixtures to use (for example fixtures for test/fixtures):
    #
    # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    #
    # == Mock Framework
    #
    # RSpec uses its own mocking framework by default. If you prefer to
    # use mocha, flexmock or RR, uncomment the appropriate line:
    #
    config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    #
    # == Notes
    #
    # For more information take a look at Spec::Runner::Configuration and Spec::Runner

    config.include Devise::TestHelpers, :type => :controller

    config.before(:all) do
      # users are not created within transactions, so delete them all here before running tests
      UserRole.delete_all
      User.delete_all

      # initialize order status constants
      @os_new        = OrderStatus.find_or_create_by_name('New')
      @os_in_process = OrderStatus.find_or_create_by_name('In Process')
      @os_complete   = OrderStatus.find_or_create_by_name('Complete')
      @os_cancelled  = OrderStatus.find_or_create_by_name('Cancelled')
      @os_reconciled  = OrderStatus.find_or_create_by_name('Reconciled')

      # initialize affiliates
      Affiliate.find_or_create_by_name('Other')

      # initialize price groups
      @nupg = PriceGroup.find_or_create_by_name(:name => 'Northwestern Base Rate', :is_internal => true, :display_order => 1)
      @nupg.save(:validate => false)
      @ccpg = PriceGroup.find_or_create_by_name(:name => 'Cancer Center Rate', :is_internal => true, :display_order => 2)
      @ccpg.save(:validate => false)
      @epg = PriceGroup.find_or_create_by_name(:name => 'External Rate', :is_internal => false, :display_order => 3)
      @epg.save(:validate => false)

      # bcsec's ensuring to satisfy bcaudit on save is
      # handled in nucore by Bcaudit::Middleware which is
      # loaded at bcsec_authenticatable's initialization.
      # Since it's rack middleware, and therefore depends
      # on being a request-response cycle, it doesn't work
      # for tests. Ideally there would be a bcsec-provided
      # mock to handle this, but there isn't, so overwrite
      # the method that ensures bcaudit satisfaction so that
      # tests can proceed. Doing so allows the NU user
      # provisioning that takes place in user_extension to
      # work, making it testable
      Pers::Base.class_eval %Q<
        protected

        def ensure_bcauditable
        end
      >
    end
  end
end


Spork.each_run do
  # used by factory to find or create order status
  def find_order_status(status)
    OrderStatus.find_or_create_by_name(status)
  end

  def assert_true(x)
    assert(x)
  end

  def assert_false(x)
    assert(!x)
  end

  def assert_not_valid(x)
    assert !x.valid?
  end

  def assert_nil(x)
    assert_equal nil, x
  end

  #
  # Asserts that the model +var+
  # no longer exists in the DB
  def should_be_destroyed(var)
    dead=false

    begin
      var.class.find var.id
    rescue
      dead=true
    end

    assert dead
  end


  #
  # Factory wrapper for creating an account with owner
  def create_nufs_account_with_owner(owner=:owner)
    owner=instance_variable_get("@#{owner.to_s}")
    Factory.create(:nufs_account, :account_users_attributes => [ Factory.attributes_for(:account_user, :user => owner) ])
  end


  #
  # Simulates placing an order for an item and having it marked complete
  # [_ordered_by_]
  #   The user who is ordering the item
  # [_facility_]
  #   The facility with which the order is placed
  # [_account_]
  #   The account under which the order is placed
  # [_reviewed_]
  #   true if the completed order should also be marked as reviewed, false by default
  def place_and_complete_item_order(ordered_by, facility, account=nil, reviewed=false)
    @facility_account=facility.facility_accounts.create(Factory.attributes_for(:facility_account))
    @item=facility.items.create(Factory.attributes_for(:item, :facility_account_id => @facility_account.id))
    @price_group=Factory.create(:price_group, :facility => facility)
    o_attrs={ :created_by => ordered_by.id, :facility => facility, :ordered_at => Time.zone.now }
    o_attrs.merge!(:account_id => account.id) if account
    @order=ordered_by.orders.create(Factory.attributes_for(:order, o_attrs))
    Factory.create(:user_price_group_member, :user => ordered_by, :price_group => @price_group)
    @item_pp=@item.item_price_policies.create(Factory.attributes_for(:item_price_policy, :price_group_id => @price_group.id))
    @item_pp.reload.restrict_purchase=false
    od_attrs={ :product_id => @item.id }
    od_attrs.merge!(:account_id => account.id) if account
    @order_detail = @order.order_details.create(Factory.attributes_for(:order_detail).update(od_attrs))
    @order_detail.change_status!(OrderStatus.complete.first)

    od_attrs={
      :actual_cost => 20,
      :actual_subsidy => 10,
      :price_policy_id => @item_pp.id
    }

    od_attrs.merge!(:reviewed_at => Time.zone.now-1.day) if reviewed
    @order_detail.update_attributes(od_attrs)
  end


  #
  # Creates a +Reservation+ for a newly created +Instrument+ that is party
  # of +facility+. The reservation is made for +order_detail+ and starts
  # at +reserve_start+. Variables +@instrument+ and +@reservation+ are
  # available for use once the method completes.
  # [_facility_]
  #   The +Facility+ for which the new +Instrument+ will be created
  # [_order_detail_]
  #   The +OrderDetail+ that the +Reservation+ will belong to
  # [_reserve_start_]
  #   An +ActiveSupport::TimeWithZone+ object representing the time the
  #   +Reservation+ should begin
  # [_extra_reservation_attrs_]
  #   Custom attributes for the +Reservation+, if any
  def place_reservation(facility, order_detail, reserve_start, extra_reservation_attrs=nil)
    facility_account=facility.facility_accounts.create(Factory.attributes_for(:facility_account))

    # create instrument, min reserve time is 60 minutes, max is 60 minutes
    @instrument=facility.instruments.create(
        Factory.attributes_for(
          :instrument,
          :facility_account => facility_account,
          :min_reserve_mins => 60,
          :max_reserve_mins => 60,
          :relay_ip => '192.168.1.1'
        )
    )

    assert @instrument.valid?
    @instrument.schedule_rules.create(Factory.attributes_for(:schedule_rule))


    res_attrs={
      :reserve_start_at => reserve_start,
      :order_detail => order_detail,
      :duration_value => 60,
      :duration_unit => 'minutes'
    }

    res_attrs.merge!(extra_reservation_attrs) if extra_reservation_attrs
    @reservation=@instrument.reservations.create(res_attrs)
  end

end
