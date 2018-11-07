require 'rails_helper'

RSpec.describe 'Admin-only merchant management' do 
  before(:each) do
    @admin = create(:admin)
    @active_merchant = create(:merchant)
    @inactive_merchant = create(:inactive_merchant)
    @user = create(:user)
  end
  it 'allows admin to disable an enabled merchant account' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'
  
    visit merchants_path

    within "#merchant-#{@active_merchant.id}" do
      click_button "Disable"
    end
    expect(current_path).to eq(merchants_path)
    within "#merchant-#{@active_merchant.id}" do
      expect(page).to_not have_button("Disable")
      expect(page).to have_button("Enable")
    end

    visit logout_path
    visit login_path
    fill_in :email, with: @active_merchant.email
    fill_in :password, with: @active_merchant.password
    click_button 'Log in'
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Your account is disabled')
  end

  it 'allows admin to enable a disabled merchant account' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'

    visit merchants_path
    within "#merchant-#{@inactive_merchant.id}" do
      click_button "Enable"
    end
    expect(current_path).to eq(merchants_path)
    within "#merchant-#{@inactive_merchant.id}" do
      expect(page).to have_button("Disable")
      expect(page).to_not have_button("Enable")
    end

    visit logout_path
    visit login_path
    fill_in :email, with: @inactive_merchant.email
    fill_in :password, with: @inactive_merchant.password
    click_button 'Log in'
    
    expect(current_path).to eq(profile_path)
  end

  it 'blocks regular users from clicking a merchant name to get to a show page' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    visit merchants_path
    expect(page).to have_content(@active_merchant.name)
    expect(page).to_not have_link(@active_merchant.name)

    visit merchant_path(@active_merchant)
    expect(page.status_code).to eq(404)
  end
  describe 'redirects admin users to a proper page' do 
    scenario 'when a user path is really a merchant' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit user_path(@active_merchant.id)
      expect(current_path).to eq(merchant_path(@active_merchant.id))
    end
    scenario 'when a merchant path is really a user' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit merchant_path(@user.id)
      expect(current_path).to eq(user_path(@user))
    end
  end
end