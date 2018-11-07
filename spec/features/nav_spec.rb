require 'rails_helper'

RSpec.describe 'Site Navigation' do 
  context 'as a visitor' do
    it 'all links work' do 
      visit root_path

      click_link 'Home'
      expect(current_path).to eq(root_path)
      click_link 'Items'
      expect(current_path).to eq(items_path)
      click_link 'Merchants'
      expect(current_path).to eq(merchants_path)
      click_link 'Cart'
      expect(current_path).to eq(carts_path)
      click_link 'Log in'
      expect(current_path).to eq(login_path)
      click_link 'Register'
      expect(current_path).to eq(register_path)
    end
  end

  context 'as a registered user' do 
    it 'all links work' do 
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit root_path

      expect(page).to_not have_link(login_path)
      expect(page).to_not have_link(register_path)

      expect(page).to have_link("Log out")

      expect(page).to have_content("Logged in as #{user.name}")

      click_link 'Profile'
      expect(current_path).to eq(profile_path)
      click_link 'Orders'
      expect(current_path).to eq(orders_path)
    end
  end

  context 'as a merchant' do 
    it 'all links work' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit root_path

      click_link 'Dashboard'
      expect(current_path).to eq(dashboard_path)
    end
  end

  context 'as an admin' do 
    it 'all links work' do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit root_path

      click_link 'Dashboard'
      expect(current_path).to eq(dashboard_path)
      click_link 'Users'
      expect(current_path).to eq(users_path)
    end
  end
end