require 'rails_helper'

RSpec.describe 'User Edit Page, aka Profile Edit' do
  before(:each) do
    @email = 'drpepper@gmail.com'
    @password = 'awesomesoda'
    @user = create(:user, email: @email, password: @password)
  end
  context 'As the user themselves' do
    it 'should allow user to edit profile data if email is still unique' do
      new_email = 'new_email@gmail.com'

      visit login_path
      fill_in :email, with: @email
      fill_in :password, with: @password
      click_button 'Log in'

      expect(current_path).to eq(profile_path)
      click_link "Edit Profile Data"
      expect(current_path).to eq(profile_edit_path)

      fill_in :user_email, with: new_email
      click_button 'Update User'

      expect(current_path).to eq(profile_path)
      within '.profile-data' do 
        expect(page).to have_content(new_email)
      end
      expect(page).to have_content("Profile data was successfully updated")
    end

    it 'should block updating if email is not unique' do
      new_email = 'new_email@gmail.com'
      user_2 = create(:user, email: new_email)
      
      visit login_path
      fill_in :email, with: @email
      fill_in :password, with: @password
      click_button 'Log in'

      visit profile_edit_path

      fill_in :user_email, with: new_email
      click_button 'Update User'

      expect(current_path).to eq(user_path(@user))
      expect(page).to have_content("Email has already been taken")
    end
  end

  context 'As an admin user' do
    before(:each) do 
      admin = create(:admin)
      @new_email = 'new_email@gmail.com'

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    it 'should allow admin to edit profile data if email is still unique' do
      visit edit_user_path(@user)

      fill_in :user_email, with: @new_email
      click_button 'Update User'

      expect(current_path).to eq(user_path(@user))
      within '.profile-data' do 
        expect(page).to have_content(@new_email)
      end
      expect(page).to have_content("Profile data was successfully updated")
    end

    it 'should block updating if email is not unique' do
      new_email = 'new_email@gmail.com'
      user_2 = create(:user, email: @new_email)

      visit edit_user_path(@user)

      fill_in :user_email, with: @new_email
      click_button 'Update User'

      expect(current_path).to eq(user_path(@user))
      expect(page).to have_content("Email has already been taken")
    end
  end
  
  describe 'other users should be blocked entirely' do
    context 'as a visitor' do 
      it 'should block a user edit page from anonymous users' do
        visit edit_user_path(@user)

        expect(page.status_code).to eq(404)
      end
    end

    context 'as another registered user' do 
      it 'should block a user edit page from other registered users' do
        user_2 = create(:user, email: 'newuser_2@gmail.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_2)

        visit edit_user_path(@user)

        expect(page.status_code).to eq(404)
      end
    end

    context 'as a merchant' do
      it 'should block a user edit page from anonymous users' do
        merchant = create(:merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit edit_user_path(@user)

        expect(page.status_code).to eq(404)
      end
    end
  end
end