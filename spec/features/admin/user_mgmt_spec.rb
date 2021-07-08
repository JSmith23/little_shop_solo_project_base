require 'rails_helper'

RSpec.describe 'Admin-only user management' do 
  before(:each) do
    @admin = create(:admin)
    @active_user = create(:user)
    @inactive_user = create(:inactive_user)
    @active_merchant = create(:merchant)
  end
  it 'allows admin to disable an enabled user account' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'
  
    visit users_path

    within "#user-#{@active_user.id}" do
      click_button "Disable"
    end
    expect(current_path).to eq(users_path)
    within "#user-#{@active_user.id}" do
      expect(page).to_not have_button("Disable")
      expect(page).to have_button("Enable")
    end

    visit logout_path
    visit login_path
    fill_in :email, with: @active_user.email
    fill_in :password, with: @active_user.password
    click_button 'Log in'
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Your account is disabled')
  end

  it 'allows admin to enable a disabled user account' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'

    visit users_path
    within "#user-#{@inactive_user.id}" do
      click_button "Enable"
    end
    expect(current_path).to eq(users_path)
    within "#user-#{@inactive_user.id}" do
      expect(page).to have_button("Disable")
      expect(page).to_not have_button("Enable")
    end

    visit logout_path
    visit login_path
    fill_in :email, with: @inactive_user.email
    fill_in :password, with: @inactive_user.password
    click_button 'Log in'
    
    expect(current_path).to eq(profile_path)
  end

  it 'allows admin to upgrade a user to a merchant' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'
  
    visit users_path

    within "#user-#{@active_user.id}" do
      expect(page).to have_content("#{@active_user.email} User")
      click_button "Upgrade to Merchant"
    end
    expect(current_path).to eq(users_path)
    within "#user-#{@active_user.id}" do
      expect(page).to have_content("#{@active_user.email} Merchant")
      expect(page).to_not have_button("Upgrade to Merchant")
      expect(page).to have_button("Downgrade to User")
    end
  end

  it 'allows admin to downgrade a merchant to a user' do
    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'
  
    visit users_path

    within "#user-#{@active_merchant.id}" do
      expect(page).to have_content("#{@active_merchant.email} Merchant")
      click_button "Downgrade to User"
    end
    expect(current_path).to eq(users_path)
    within "#user-#{@active_merchant.id}" do
      expect(page).to have_content("#{@active_merchant.email} User")
      expect(page).to have_button("Upgrade to Merchant")
      expect(page).to_not have_button("Downgrade to User")
    end
  end
end