require 'spec_helper'

describe Account do
  def unopen_account(account_number)
    components = ValidatorFactory.instance(account_number).components.reject do |k,v|
      v.nil?
    end
    components[:department] = components.delete(:dept)
    NucsGl066.where(components).destroy_all
  end

  context "validation against product/user" do
    before(:each) do
      @facility          = FactoryGirl.create(:facility)
      @user              = FactoryGirl.create(:user)
      @nufs_account      = FactoryGirl.create(:nufs_account, :account_users_attributes => account_users_attributes_hash(:user => @user))
      @facility_account  = @facility.facility_accounts.create(FactoryGirl.attributes_for(:facility_account))
      @item              = @facility.items.create(FactoryGirl.attributes_for(:item, :facility_account_id => @facility_account.id))
      @price_group       = FactoryGirl.create(:price_group, :facility => @facility)
      @price_group_product=FactoryGirl.create(:price_group_product, :product => @item, :price_group => @price_group, :reservation_window => nil)
      @price_policy      = FactoryGirl.create(:item_price_policy, :product => @item, :price_group => @price_group)
      @pg_user_member    = FactoryGirl.create(:user_price_group_member, :user => @user, :price_group => @price_group)
    end

    it "should return error if the product's account is not open for a chart string" do
      unopen_account(@nufs_account.account_number)
      expect(@nufs_account.validate_against_product(@item, @user)).not_to be_nil
    end

    context 'bundles' do
      before :each do
        @item2 = @facility.items.create(FactoryGirl.attributes_for(:item, :account => 78960, :facility_account_id => @facility_account.id))
        @bundle = @facility.bundles.create(FactoryGirl.attributes_for(:bundle, :facility_account_id => @facility_account.id))
        [ @item, @item2 ].each{|item| BundleProduct.create!(:quantity => 1, :product => item, :bundle => @bundle) }
      end

      it "should return error if the product is a bundle and one of the bundled product's account is not open for a chart string" do
        cs='191-5401900-60006385-01-1059-1095' # a grant chart string
        define_open_account(NUCore::COMMON_ACCOUNT, cs) # define the string so it is valid on NufsAccount#validate
        @nufs_account.account_number=cs
        assert @nufs_account.save
        define_open_account(@item.account, cs) # only one product of the bundle should be open
        expect(@nufs_account.validate_against_product(@bundle, @user)).not_to be_nil
      end
    end

  end
end
