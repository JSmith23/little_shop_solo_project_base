require 'rails_helper'

RSpec.describe 'User Show Page, aka Profile Page' do
  before(:each) do
    @user = create(:user)
  end
  context 'As the user themselves' do
    it 'should show all user data to themselves' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path
      within '.profile-data' do
        expect(page).to have_content(@user.email)
        expect(page).to have_content(@user.name)
        expect(page).to have_content(@user.address)
        expect(page).to have_content(@user.city)
        expect(page).to have_content(@user.state)
        expect(page).to have_content(@user.zip)

        click_link "Edit Profile Data"
        expect(current_path).to eq(profile_edit_path)
      end
      expect(page).to_not have_link("View Personal Orders")
    end
    it 'should show the user a link to their personal orders if user has any' do
      order = create(:order, user: @user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      click_link("View Personal Orders")

      expect(current_path).to eq(profile_orders_path)
    end
  end

  context 'As an admin user' do
    it 'should show all user data to an admin' do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit user_path(@user.path_keys)
      within '.profile-data' do
        expect(page).to have_content(@user.email)
        expect(page).to have_content(@user.name)
        expect(page).to have_content(@user.address)
        expect(page).to have_content(@user.city)
        expect(page).to have_content(@user.state)
        expect(page).to have_content(@user.zip)

        click_link "Edit Profile Data"
        expect(current_path).to eq(edit_user_path(@user.path_keys))
      end
      expect(page).to_not have_link("View Personal Orders")
    end
    it 'should show a link to orders if user has any' do
      order = create(:order, user: @user)
      admin = create(:admin)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit user_path(@user.path_keys)

      click_link("View Personal Orders")
      expect(current_path).to eq(user_orders_path(@user))
    end
  end

  describe 'Invalid permissions' do
    context 'as a visitor' do
      it 'should block a user profile page from anonymous users' do
        visit user_path(@user.path_keys)

        expect(page.status_code).to eq(404)
      end
      it 'should block anonymous users trying to get to a profile path' do
        visit profile_path

        expect(page.status_code).to eq(404)
      end
    end

    context 'as another registered user' do
      it 'should block a user profile page from other registered users' do
        user_2 = create(:user, email: 'newuser_2@gmail.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_2)

        visit user_path(@user.path_keys)

        expect(page.status_code).to eq(404)
      end
      it 'should block access to /dashboard' do
        order = create(:order, user: @user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit dashboard_path

        expect(page.status_code).to eq(404)
      end
      it 'should block access to /dashboard' do
        order = create(:order, user: @user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit dashboard_path

        expect(page.status_code).to eq(404)
      end
    end

    context 'as a merchant' do
      it 'should block a user profile page from anonymous users' do
        merchant = create(:merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit user_path(@user.path_keys)

        expect(page.status_code).to eq(404)
      end
    end
  end
end
