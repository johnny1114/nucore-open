class NavTab::LinkCollection

  include Rails.application.routes.url_helpers
  include TranslationHelper

  attr_reader :ability, :facility

  delegate :single_facility?, to: :facility

  def initialize(facility, ability)
    @facility = facility
    @ability = ability
  end

  def self.tab_methods
    @tab_methods ||= %i(
      admin_orders
      admin_reservations
      admin_billing
      admin_products
      admin_users
      admin_reports
      admin_facility
    )
  end

  def admin
    default + admin_only
  end

  def customer
    default + [orders, reservations, accounts, files]
  end

  def default
    [home]
  end

  private

  def accounts
    NavTab::Link.new(tab: :accounts, text: t_my(Account), url: accounts_path)
  end

  def files
    NavTab::Link.new(tab: :my_files, text: I18n.t("views.my_files.index.header"), url: my_files_path) if SettingsHelper.feature_on?(:my_files)
  end

  def admin_billing
    if single_facility? && ability.can?(:manage_billing, facility)
      NavTab::Link.new(tab: :admin_billing, url: billing_tab_landing_path)
    end
  end

  def admin_only
    self.class.tab_methods.map do |tab_method|
      send(tab_method)
    end.select(&:present?)
  end

  def admin_orders
    if single_facility? && ability.can?(:administer, Order)
      NavTab::Link.new(tab: :admin_orders, url: facility_orders_path(facility))
    end
  end

  def admin_products
    if single_facility? && ability.can?(:administer, Product)
      NavTab::Link.new(tab: :admin_products, url: facility_products_path(facility))
    end
  end

  def admin_reports
    if single_facility? && ability.can?(:manage, Reports::ReportsController)
      NavTab::Link.new(
        tab: :admin_reports,
        subnav: [general_reports, instrument_utilization_reports],
      )
    end
  end

  def admin_reservations
    if single_facility? && ability.can?(:administer, Reservation)
      NavTab::Link.new(
        tab: :admin_reservations,
        url: timeline_facility_reservations_path(facility),
      )
    end
  end

  def admin_users
    if single_facility? && ability.can?(:administer, User)
      NavTab::Link.new(tab: :admin_users, url: facility_users_path(facility))
    end
  end

  def admin_facility
    if ability.can?(:edit, facility)
      NavTab::Link.new(tab: :admin_facility, url: manage_facility_path(facility))
    end
  end

  def billing_tab_landing_path
    if SettingsHelper.has_review_period?
      facility_notifications_path(facility)
    else
      facility_transactions_path(facility)
    end
  end

  def general_reports
    NavTab::Link.new(
      text: I18n.t("pages.general_reports"),
      url: facility_general_reports_path(facility, report_by: :product),
    )
  end

  def home
    NavTab::Link.new(tab: :home, url: root_path)
  end

  def instrument_utilization_reports
    NavTab::Link.new(
      text: I18n.t("pages.instrument_utilization_reports"),
      url: facility_instrument_reports_path(facility, report_by: :instrument),
    )
  end

  def orders
    NavTab::Link.new(tab: :orders, text: t_my(Order), url: orders_path)
  end

  def reservations
    NavTab::Link.new(
      tab: :reservations,
      text: t_my(Reservation),
      url: reservations_path,
    )
  end

end
