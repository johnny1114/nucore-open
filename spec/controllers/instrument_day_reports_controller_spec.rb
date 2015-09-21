require "rails_helper"
require 'controller_spec_helper'
require 'report_spec_helper'

RSpec.describe InstrumentDayReportsController do
  include ReportSpecHelper


  run_report_tests([
    { :action => :reserved_quantity, :index => 4, :report_on_label => nil, :report_on => Proc.new{|res| Reports::InstrumentDayReport::ReservedQuantity.new(res) } },
    { :action => :reserved_hours, :index => 5, :report_on_label => nil, :report_on => Proc.new{|res| Reports::InstrumentDayReport::ReservedHours.new(res) } },
    { :action => :actual_quantity, :index => 6, :report_on_label => nil, :report_on => Proc.new{|res| Reports::InstrumentDayReport::ActualQuantity.new(res) } },
    { :action => :actual_hours, :index => 7, :report_on_label => nil, :report_on => Proc.new{|res| Reports::InstrumentDayReport::ActualHours.new(res) } }
  ])


  private

  def setup_extra_test_data(user)
    start_at=parse_usa_date(@params[:date_start], '10:00 AM')+10.days
    place_reservation(@authable, @order_detail, start_at)
    @reservation.actual_start_at=start_at
    @reservation.actual_end_at=start_at+1.hour
    assert @reservation.save(:validate => false)
  end


  def report_headers(label)
    headers=[ 'Instrument', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' ]
    headers += report_attributes(@reservation, @instrument) if export_all_request?
    headers
  end


  def assert_report_init(label, &report_on)
    expect(assigns(:totals)).to be_is_a Array
    expect(assigns(:totals).size).to eq(7)

    ndx=@reservation.actual_start_at.wday
    assigns(:totals).each_with_index do |sum, i|
      if i == ndx
        expect(sum).to be > 0
      else
        expect(sum).to eq(0)
      end
    end

    instruments=Instrument.all
    expect(assigns(:rows)).to be_is_a Array
    expect(assigns(:rows).size).to eq(instruments.count)

    assigns(:rows).each do |row|
      expect(row.size).to eq(8)
      expect(instruments.collect(&:name)).to be_include(row[0])
      row[1..-1].all?{|data| expect(data).to be_is_a(Numeric)}
    end
  end


  def assert_report_data_init(label)
    expect(assigns(:report_data)).to eq(Reservation.all)
  end

end
