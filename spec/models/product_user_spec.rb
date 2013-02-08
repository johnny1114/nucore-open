require 'spec_helper'

describe ProductUser do
  it "can be created with valid attributes" do
    @facility         = FactoryGirl.create(:facility)
    @facility_account = @facility.facility_accounts.create(FactoryGirl.attributes_for(:facility_account))
    @item             = @facility.items.create(FactoryGirl.attributes_for(:item, :facility_account_id => @facility_account.id, :requires_approval => true))
    @user             = FactoryGirl.create(:user)

    @product_user     = ProductUser.create({:product => @item, :user => @user, :approved_by => @user.id})
    @product_user.should be_valid
  end
  
  it "should assign approved_at on creation" do
    @facility         = FactoryGirl.create(:facility)
    @facility_account = @facility.facility_accounts.create(FactoryGirl.attributes_for(:facility_account))
    @item             = @facility.items.create(FactoryGirl.attributes_for(:item, :facility_account_id => @facility_account.id, :requires_approval => true))
    @user             = FactoryGirl.create(:user)

    @product_user     = ProductUser.create({:product => @item, :user => @user, :approved_by => @user.id})
    @product_user.approved_at.should_not be_nil
  end
  
  it "requires approved_by" do
    @product_user = ProductUser.new({:approved_by => nil})
    @product_user.should_not be_valid
    @product_user.errors[:approved_by].should_not be_nil
    
    @product_user = ProductUser.new({:approved_by => 1})
    @product_user.valid?
    @product_user.errors[:approved_by].should be_empty
  end
  
  it "requires product_id" do
    @product_user = ProductUser.new({:product_id => nil})
    @product_user.should_not be_valid
    @product_user.errors[:product_id].should_not be_nil
    
    @product_user = ProductUser.new({:product_id => 1})
    @product_user.valid?
    @product_user.errors[:product_id].should be_empty
  end
  
  it "requires user_id" do
    @product_user = ProductUser.new({:user_id => nil})
    @product_user.should_not be_valid
    @product_user.errors[:user_id].should_not be_nil
    
    @product_user = ProductUser.new({:user_id => 1})
    @product_user.valid?
    @product_user.errors[:user_id].should be_empty
  end
end
