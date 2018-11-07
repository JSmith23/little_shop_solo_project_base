require 'rails_helper'

RSpec.describe 'Admin Stats' do
  context 'as an admin, viewing my dashboard' do 
    before(:each) do
      @admin = create(:admin)
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @user_1 = create(:user, city: 'Denver', state: 'CO')
      @user_2 = create(:user, city: 'Los Angeles', state: 'CA')
      @user_3 = create(:user, city: 'Tampa', state: 'FL')
      @user_4 = create(:user, city: 'NYC', state: 'NY')

      @item_1 = create(:item, user: @merchant_1)

      # Denver/Colorado is 2nd place
      @order_1 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: @order_1, item: @item_1)
      @order_2 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: @order_2, item: @item_1)
      @order_3 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: @order_3, item: @item_1)
      # Los Angeles, California is 1st place
      @order_4 = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: @order_4, item: @item_1)
      @order_5 = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: @order_5, item: @item_1)
      @order_6 = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: @order_6, item: @item_1)
      @order_7 = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: @order_7, item: @item_1)
      # Sorry Tampa, Florida
      @order_8 = create(:completed_order, user: @user_3)
      create(:fulfilled_order_item, order: @order_8, item: @item_1)
      # NYC, NY is 3rd place
      @order_9 = create(:completed_order, user: @user_4)
      create(:fulfilled_order_item, order: @order_9, item: @item_1)
      @order_A = create(:completed_order, user: @user_4)
      create(:fulfilled_order_item, order: @order_A, item: @item_1)
    end
    it 'shows top 3 states where items were shipped' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit dashboard_path

      within '#stats' do
        within '#stats-top-states' do
          expect(page).to have_content("Top 3 States:\n#{@user_2.state} #{@user_1.state} #{@user_4.state}")
        end
      end
    end
    it 'shows top 3 cities where items were shipped' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit dashboard_path

      within '#stats' do
        within '#stats-top-cities' do
          expect(page).to have_content("Top 3 Cities:\n#{@user_2.city} #{@user_1.city} #{@user_4.city}")
        end
      end
    end
    it 'shows largest order by quantity of my items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit dashboard_path

      within '#stats-biggest-orders' do
        orders = Order.biggest_orders(3)
        expect(page).to have_content("Order ##{orders[0].id} by #{orders[0].user.name}, #{orders[0].item_count} items")
        expect(page).to have_content("Order ##{orders[1].id} by #{orders[1].user.name}, #{orders[1].item_count} items")
        expect(page).to have_content("Order ##{orders[2].id} by #{orders[2].user.name}, #{orders[2].item_count} items")
      end
    end
    it 'shows top 3 spending users' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit dashboard_path
      within '#stats-top-buyers' do
        buyers = Order.top_buyers(3)
        expect(page).to have_content("#{buyers[0].name}, $#{buyers[0].total_spent}")
        expect(page).to have_content("#{buyers[1].name}, $#{buyers[1].total_spent}")
        expect(page).to have_content("#{buyers[2].name}, $#{buyers[2].total_spent}")
      end
    end
    it 'shows top 3 earning merchants' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit dashboard_path
      within '#stats-top-merchants' do
        merchants = User.top_merchants(3)
        expect(page).to have_content("#{merchants[0].name}, $#{merchants[0].total_earned}")
        expect(page).to have_content("#{merchants[1].name}, $#{merchants[1].total_earned}")
        expect(page).to have_content("#{merchants[2].name}, $#{merchants[2].total_earned}")
      end    
    end
  end
end