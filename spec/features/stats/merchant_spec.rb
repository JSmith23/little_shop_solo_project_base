require 'rails_helper'

RSpec.describe 'Merchant Stats' do
  context 'as a merchant, viewing my dashboard' do 
    before(:each) do
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
    it 'shows total items I have sold and as a percentage of inventory' do
      merchant_1, merchant_2 = create_list(:merchant, 2)
      total_units = 100
      sold_units = 20
      item_1 = create(:item, inventory: total_units, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      order = create(:completed_order)
      oi_1 = create(:fulfilled_order_item, quantity: sold_units, order: order, item: item_1)
      oi_2 = create(:fulfilled_order_item, order: order, item: item_2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_1)

      visit dashboard_path

      within '#stats' do
        within '#inv-stats' do
          expect(page).to have_content("Total Items Sold: #{sold_units}")
          expect(page).to have_content("Represents #{(sold_units/total_units*100).round(2)}% of Inventory")
        end
      end
    end
    it 'shows top 3 states where I have shipped items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path

      within '#stats' do
        within '#stats-top-states' do
          expect(page).to have_content("Top 3 States:\n#{@user_2.state} #{@user_1.state} #{@user_4.state}")
        end
      end
    end
    it 'shows top 3 cities where I have shipped items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path

      within '#stats' do
        within '#stats-top-cities' do
          expect(page).to have_content("Top 3 Cities:\n#{@user_2.city} #{@user_1.city} #{@user_4.city}")
        end
      end
    end
    it 'shows most active user buying my items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      # user 2 is winning at first
      visit dashboard_path
      within '#stats' do
        active_user = @merchant_1.top_active_user
        expect(page).to have_content("Most Active Buying User: #{@user_2.name}, #{active_user.order_count} orders")
      end
      # but if we disable this user, confirm user 1 is next best
      @user_2.update(active: false)

      visit dashboard_path
      within '#stats' do
        active_user = @merchant_1.top_active_user
        expect(page).to have_content("Most Active Buying User: #{@user_1.name}, #{active_user.order_count} orders")
      end
    end
    it 'shows largest order by quantity of my items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path
      within '#stats' do
        within '#stats-biggest-order' do
          expect(page).to have_content("Order ##{@order_A.id}, worth $#{@order_A.total}")
          expect(page).to have_content("It had #{@merchant_1.biggest_order.item_count} items of yours in the order")
        end
      end
    end
    it 'shows top 3 spending users who bought my items' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path
      within '#stats' do
        within '#stats-top-buyers' do
          buyers = @merchant_1.top_buyers(3)
          expect(page).to have_content("#{buyers[0].name}, $#{buyers[0].total_spent}")
          expect(page).to have_content("#{buyers[1].name}, $#{buyers[1].total_spent}")
          expect(page).to have_content("#{buyers[2].name}, $#{buyers[2].total_spent}")
        end
      end
    end
  end
end