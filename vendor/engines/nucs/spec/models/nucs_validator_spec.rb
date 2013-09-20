require 'spec_helper'
require_relative '../support/nucs_validator_helper'

include NucsValidatorHelper

describe NucsValidator do

  REVENUE_ACCT='50617'
  NON_REVENUE_ACCT='75340'
  NON_GRANT_CS='171-5401900-10006385-01-1059-1095'
  GRANT_CS=NON_GRANT_CS.gsub('171-', '191-').gsub('10006385', '60006385') # 191-5401900-60006385-01-1059-1095
  ZERO_FUND_CS=NON_GRANT_CS.gsub('171-', '023-') # 023-5401900-10006385-01-1059-1095


  it 'should require a valid account' do
    assert_raise NucsErrors::InputError do
      NucsValidator.new(NON_GRANT_CS, 'kfjdksjdfks')
    end
  end


  it 'should require a valid account on account=' do
    assert_raise NucsErrors::InputError do
      validator=NucsValidator.new(NON_GRANT_CS, REVENUE_ACCT)
      validator.account='kfjdksjdfks'
    end
  end


  it 'should require a valid chart string' do
    assert_raise NucsErrors::InputError do
      NucsValidator.new('kfjdksjdfks', REVENUE_ACCT)
    end
  end


  it 'should require a valid chart string on chart_string= ' do
    assert_raise NucsErrors::InputError do
      validator=NucsValidator.new(NON_GRANT_CS, REVENUE_ACCT)
      validator.chart_string='kfjdksjdfks'
    end
  end

  it 'should allow just a fund and department' do
    validator = NucsValidator.new('123-1234567')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567'})
  end

  it 'should allow a fund, department, and project' do
    validator = NucsValidator.new('123-1234567-12345678')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678'})
  end

  it 'should not allow a four digit project' do
    expect { NucsValidator.new('123-1234567-1234') }.to raise_error(NucsErrors::InputError)
  end

  it 'should not allow a two digit project' do
    expect { NucsValidator.new('123-1234567-12') }.to raise_error(NucsErrors::InputError)
  end

  it 'should allow averything and an activity' do
    validator = NucsValidator.new('123-1234567-12345678-12')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678', :activity => '12'})
  end

  it 'should allow everything with a program' do
    validator = NucsValidator.new('123-1234567-12345678-12-1234')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678', :activity => '12', :program => '1234'})
  end

  it 'should allow everything including chart_field1' do
    validator = NucsValidator.new('123-1234567-12345678-12-1234-4321')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678', :activity => '12', :program => '1234', :chart_field1 => '4321'})
  end

  it 'should allow skipping program' do
    validator = NucsValidator.new('123-1234567-12345678-12--1234')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678', :activity => '12', :chart_field1 => '1234'})
  end

  # this might be incorrect, but asserting for now
  it 'should allow skipping activity' do
    validator = NucsValidator.new('123-1234567-12345678-1234')
    expect(validator.components.reject { |k, v| v.nil? }).to eq({:fund => '123', :dept => '1234567', :project => '12345678', :program => '1234'})
  end

  # tests below are commented out because they test logic overridden by blacklist requirements

#  it 'should validate a zero fund chart string' do
#    define_ge001(ZERO_FUND_CS)
#    assert_nothing_raised do
#      NucsValidator.new(ZERO_FUND_CS, NON_REVENUE_ACCT).account_is_open!
#    end
#  end


#  it 'should recognize an invalid zero fund chart string' do
#    assert_raise NucsErrors::InputError do
#      NucsValidator.new(ZERO_FUND_CS.gsub('023-', '034-'), NON_REVENUE_ACCT).account_is_open!
#    end
#  end


#  it 'should recognize a transposition on a 011 zero fund chart string' do
#    assert_raise NucsErrors::TranspositionError do
#      NucsValidator.new(ZERO_FUND_CS.gsub('023-', '011-'), NON_REVENUE_ACCT).account_is_open!
#    end
#  end


  it 'should validate a non-grant chart string on a revenue account' do
    define_ge001(NON_GRANT_CS)
    assert_nothing_raised do
      NucsValidator.new(NON_GRANT_CS, REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize a bad fund on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('171-', '166-'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'fund')
  end


  it 'should recognize a bad department on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('5401900', '5401922'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'department')
  end


  it 'should recognize a bad project on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('10006385', '10006366'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'project')
  end


  it 'should recognize a bad activity on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('-01-', '-02-'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'activity')
  end


  it 'should recognize a bad program on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('1059', '1066'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'program')
  end


  it 'should recognize a bad chart field on a revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('1095', '2000'), REVENUE_ACCT)
    assert_unknown_ge001(validator, 'chart field 1')
  end


  it 'should validate a non-grant chart string on a non-revenue account' do
    define_gl066(NON_GRANT_CS)
    assert_nothing_raised do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize a bad fund on a non-revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('171-', '170-'), NON_REVENUE_ACCT)
    assert_unknown_gl066(validator)
  end


  it 'should recognize a bad department on a non-revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('5401900', '5401910'), NON_REVENUE_ACCT)
    assert_unknown_gl066(validator)
  end


  it 'should recognize a bad project on a non-revenue account' do
    validator=NucsValidator.new(NON_GRANT_CS.gsub('5401900', '5401910'), NON_REVENUE_ACCT)
    assert_unknown_gl066(validator)
  end


  it 'should not require a project on a non-grant chart string' do
    define_gl066(NON_GRANT_CS)
    chart_string=NON_GRANT_CS[0...NON_GRANT_CS.index('-', NON_GRANT_CS.index('-')+1)]
    assert_nothing_raised do
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize an expired chart string on a GL066 entry with dates' do
    define_gl066(NON_GRANT_CS, :expires_at => Time.zone.today-1)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize an uninitiated chart string on a GL066 entry with dates' do
    define_gl066(NON_GRANT_CS, :starts_at => Time.zone.today+1, :expires_at => Time.zone.today+1.year)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize an expired chart string on a GL066 entry without dates' do
    define_gl066(NON_GRANT_CS, :budget_period => '2000')
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should not raise an error if chart string is expired, compared with a prior fulfillment date, and is in 90 day window' do
    today=Time.zone.today
    define_gl066(NON_GRANT_CS, :expires_at => today-1)
    assert_nothing_raised do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!((today-2).to_datetime)
    end
  end


  it 'should not raise an error if chart string has an expired and unexpired record and no fulfillment date is given.' do
    today=Time.zone.today
    define_gl066(NON_GRANT_CS, :expires_at => today-1.year)
    define_gl066(NON_GRANT_CS, :expires_at => today+1.day)
    assert_nothing_raised do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should raise an error if chart string is expired, compared with a post fulfillment date, and is in 90 day window' do
    today=Time.zone.today
    define_gl066(NON_GRANT_CS, :expires_at => today-1)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!(today.to_datetime)
    end
  end


  it 'should raise an error if chart string is expired, compared with a prior fulfillment date, and is outside the 90 day window' do
    today=Time.zone.today
    Timecop.freeze today+91.days do
      define_gl066(NON_GRANT_CS, :expires_at => today-1)
      assert_raise NucsErrors::DatedGL066Error do
        NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!((today-2).to_datetime)
      end
    end
  end


  it 'should validate a grant chart string on a non-revenue account' do
    define_open_account(NON_REVENUE_ACCT, GRANT_CS)
    assert_nothing_raised do
      NucsValidator.new(GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should require an activity for a grant chart string on a non-revenue account' do
    define_open_account(NON_REVENUE_ACCT, GRANT_CS)
    assert_raise NucsErrors::InputError do
      chart_string=GRANT_CS[0...GRANT_CS.index('-01')]
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should require an activity for a non-grant chart string with project id on a non-revenue account' do
    define_open_account(NON_REVENUE_ACCT, NON_GRANT_CS)
    assert_raise NucsErrors::InputError do
      chart_string=NON_GRANT_CS[0...NON_GRANT_CS.index('-01')]
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should validate an activity for a grant chart string on a non-revenue account' do
    validator=NucsValidator.new(GRANT_CS.gsub('-01-', '-02-'), NON_REVENUE_ACCT)
    assert_unknown_gl066(validator, GRANT_CS, NON_REVENUE_ACCT)
  end


  it 'should confirm that an account is open for a chart string' do
    define_open_account(NON_REVENUE_ACCT, NON_GRANT_CS)
    assert_nothing_raised do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize a missing budget tree' do
    FactoryGirl.create(:nucs_grants_budget_tree)
    define_gl066(GRANT_CS)
    assert_raise NucsErrors::UnknownBudgetTreeError do
      NucsValidator.new(GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should recognize a closed account for a chart string' do
    define_open_account(NON_REVENUE_ACCT, NON_GRANT_CS, {}, :budget_period => '2000')
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(NON_GRANT_CS, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should confirm when all GE001 components are found' do
    define_ge001(NON_GRANT_CS)
    validator=NucsValidator.new(NON_GRANT_CS)
    validator.should be_components_exist
  end


  it 'should acknowledge when a GE001 component is missing' do
    define_ge001(NON_GRANT_CS)
    validator=NucsValidator.new(NON_GRANT_CS.gsub('171-', '161-'))
    validator.should_not be_components_exist
  end


  it 'should return the later of matching expiration dates' do
    three_year_later=Time.zone.now + 3.year
    define_gl066(NON_GRANT_CS, :expires_at => three_year_later-2.year)
    define_gl066(NON_GRANT_CS, :expires_at => three_year_later-1.year)
    define_gl066(NON_GRANT_CS, :expires_at => three_year_later)
    NucsValidator.new(NON_GRANT_CS).latest_expiration.year.should == three_year_later.year
  end


  it 'should return nil when there is no match on components' do
    define_gl066(NON_GRANT_CS, :expires_at => Time.zone.now + 3.year)
    NucsValidator.new(NON_GRANT_CS.gsub('171-', '161-')).latest_expiration.should be_nil
  end


  it 'should return nil when there is no project given, but one exists in the DB' do
    define_gl066(NON_GRANT_CS, :expires_at => Time.zone.now + 3.year)
    NucsValidator.new(NON_GRANT_CS[0...NON_GRANT_CS.index('-10006385')]).latest_expiration.should be_nil
  end


  it 'should return a date when there is no project given and "-" exists in the DB' do
    define_gl066(NON_GRANT_CS, {
      :expires_at => Time.zone.now + 3.year,
      :project => NucsValidator::NUCS_BLANK,
      :activity => NucsValidator::NUCS_BLANK
    })

    NucsValidator.new(NON_GRANT_CS[0...NON_GRANT_CS.index('-10006385')]).latest_expiration.should_not be_nil
  end


  it 'should return a date when there is no activity given and "-" exists in the DB' do
    define_gl066(NON_GRANT_CS, { :expires_at => Time.zone.now + 3.year, :activity => NucsValidator::NUCS_BLANK })
    NucsValidator.new(NON_GRANT_CS[0...NON_GRANT_CS.index('-01')]).latest_expiration.should_not be_nil
  end


  it 'should return nil when the matching GL066 entry is expired' do
    define_gl066(NON_GRANT_CS, :expires_at => Time.zone.now-1.year)
    NucsValidator.new(NON_GRANT_CS).latest_expiration.should be_nil
  end


  it 'should error on blacklisted fund' do
    Blacklist::DISALLOWED_FUNDS.each do |fund|
      blacklisted=NON_GRANT_CS.gsub('171-', "#{fund}-")
      assert_raise NucsErrors::BlacklistedError do
        NucsValidator.new(blacklisted)
      end
    end
  end


  it 'should error on blacklisted account' do
    [ '0', '1', '2', '3', '4', '6', '8', '9' ].each do |i|
      blacklisted=i + REVENUE_ACCT[1..-1]
      assert_raise NucsErrors::BlacklistedError do
        NucsValidator.new(NON_GRANT_CS, blacklisted)
      end
    end
  end


  #
  # Test AcctngChartStringConstructionRules.pdf logic in #validate_gl066_PAD_components!
  #

  it 'should not allow a project when fund >= 100 and <= 169' do
    chart_string=GRANT_CS.gsub('191-', '111-')
    define_open_account(NON_REVENUE_ACCT, chart_string)

    assert_raise NucsErrors::NotAllowedError do
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end
  end


  it 'should not allow a project that does not start with 1 when fund >= 170 and <= 179' do
    assert_project_input_error GRANT_CS.gsub('191-', '175-')
  end


  it 'should not allow a project that does not start with 6 when fund >= 191 and <= 199' do
    assert_project_input_error GRANT_CS.gsub('60006385', '40006385')
  end


  it 'should not allow a project that does not start with 3 when fund >= 300 and <= 320' do
    assert_project_input_error GRANT_CS.gsub('191-', '315-')
  end


  it 'should not allow an activity other than 01 when fund is >= 410 and <= 483' do
    chart_string=GRANT_CS.gsub('191-', '411-').gsub('-01-', '-02-')
    define_open_account(NON_REVENUE_ACCT, chart_string)

    exception=assert_raise NucsErrors::InputError do
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end

    exception.message.should be_end_with 'activity'
  end


  it 'should not allow a project that does not start with 5 when fund >= 500 and <= 540' do
    assert_project_input_error GRANT_CS.gsub('191-', '505-')
  end


  it 'should not allow a project that does not start with 6 when fund >= 600 and <= 650' do
    assert_project_input_error GRANT_CS.gsub('191-', '605-').gsub('60006385', '40006385')
  end


  it 'should not allow a project that does not start with 7 when fund >= 700 and <= 740' do
    assert_project_input_error GRANT_CS.gsub('191-', '701-')
  end


  it 'should not allow a project that does not start with 7 when fund is 750' do
    assert_project_input_error GRANT_CS.gsub('191-', '750-')
  end


  it 'should not allow a project that does not start with 8 when fund >= 800 and <= 840' do
    assert_project_input_error GRANT_CS.gsub('191-', '810-')
  end


  it 'should consider whitelisted chart strings always open' do
    validator=NucsValidator.new(Whitelist::ALLOWED_CHART_STRINGS[0], NON_REVENUE_ACCT)
    assert_nothing_raised { validator.account_is_open! }
  end


  def assert_project_input_error(chart_string)
    define_open_account(NON_REVENUE_ACCT, chart_string)

    exception=assert_raise NucsErrors::InputError do
      NucsValidator.new(chart_string, NON_REVENUE_ACCT).account_is_open!
    end

    exception.message.should be_end_with 'project'
  end


  def assert_unknown_gl066(validator, chart_string=NON_GRANT_CS, account=nil)
    if account
      define_open_account(account, chart_string)
    else
      define_gl066(chart_string)
    end

    assert_raise NucsErrors::UnknownGL066Error do
      validator.account_is_open!
    end
  end


  def assert_unknown_ge001(validator, failed_component_name, chart_string=NON_GRANT_CS)
    define_ge001(chart_string)

    begin
      validator.account_is_open!
    rescue NucsErrors::UnknownGE001Error => e
      e.message.should be_end_with(failed_component_name)
    else
      assert false
    end
  end

end
