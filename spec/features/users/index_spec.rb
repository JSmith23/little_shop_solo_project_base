require 'rails_helper'

RSpec.describe 'User Index Page, only for admins' do
  context 'As an admin user' do
    before(:each) do 
      @admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
    end

    it 'should show all users' do
      @user_1, @user_2, @user_3 = create_list(:user, 3)

      visit users_path

      within "#user-#{@user_1.id}" do
        expect(page).to have_link(@user_1.email)
      end
      within "#user-#{@user_2.id}" do
        expect(page).to have_link(@user_2.email)
      end
      within "#user-#{@user_3.id}" do
        expect(page).to have_link(@user_3.email)
      end
    end
    it 'should show enable/disable buttons as appropriate' do
      @user_1 = create(:user)
      @user_2 = create(:inactive_user)

      visit users_path

      within "#user-#{@user_1.id}" do
        expect(page).to have_button("Disable")
      end
      within "#user-#{@user_2.id}" do
        expect(page).to have_button("Enable")
      end
    end
  end
end

describe 'Invalid permissions' do
  context 'as a visitor' do 
    it 'should block user index page from anonymous users' do
      visit users_path

      expect(page.status_code).to eq(404)
    end
  end

  context 'as a registered user' do 
    it 'should block user index page from other registered users' do
      new_user = create(:user, email: 'newuser_2@gmail.com')
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(new_user)

      visit users_path

      expect(page.status_code).to eq(404)
    end
  end
  
  context 'as a merchant' do
    it 'should block user index page from anonymous users' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit users_path

      expect(page.status_code).to eq(404)
    end
  end
end