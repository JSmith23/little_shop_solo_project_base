require 'rails_helper'

RSpec.describe 'Item Stats' do
  context 'seeing stats when visiting /items' do
    before(:each) do
      @user = create(:user)
      @merchants = create_list(:merchant, 10)
      @item_1 = create(:item, user: @merchants[0])
      @item_2 = create(:item, user: @merchants[1])
      @item_3 = create(:item, user: @merchants[2])
      @item_4 = create(:item, user: @merchants[3])
      @item_5 = create(:item, user: @merchants[4])
      @item_6 = create(:item, user: @merchants[5])
      @item_7 = create(:item, user: @merchants[6])
      @item_8 = create(:item, user: @merchants[7])
      @item_9 = create(:item, user: @merchants[8])
      @item_A = create(:item, user: @merchants[9])
    end
    it 'shows 5 most popular items' do
      orders = create_list(:completed_order, 1, user: @user)
      create(:fulfilled_order_item, order: orders[0], item: @item_9, quantity: 6)
      create(:fulfilled_order_item, order: orders[0], item: @item_5, quantity: 10)
      create(:fulfilled_order_item, order: orders[0], item: @item_2, quantity: 4)
      create(:fulfilled_order_item, order: orders[0], item: @item_8, quantity: 7)
      create(:fulfilled_order_item, order: orders[0], item: @item_3, quantity: 3)

      visit items_path
      within('#stats') do
        within('#popular-items') do
        popular = Item.popular_items(5)
          expect(page).to have_content("#{@item_5.name}, ordered #{popular[0].total_ordered} times")
          expect(page).to have_content("#{@item_8.name}, ordered #{popular[1].total_ordered} times")
          expect(page).to have_content("#{@item_9.name}, ordered #{popular[2].total_ordered} times")
          expect(page).to have_content("#{@item_2.name}, ordered #{popular[3].total_ordered} times")
          expect(page).to have_content("#{@item_3.name}, ordered #{popular[4].total_ordered} times")
        end
      end
    end
    it 'shows 5 most popular merchants' do
      orders = create_list(:completed_order, 5, user: @user)
      create(:fulfilled_order_item, order: orders[0], item: @item_9, quantity: 6)
      create(:fulfilled_order_item, order: orders[0], item: @item_8, quantity: 6)
      create(:fulfilled_order_item, order: orders[1], item: @item_5, quantity: 10)
      create(:fulfilled_order_item, order: orders[1], item: @item_1, quantity: 10)
      create(:fulfilled_order_item, order: orders[2], item: @item_2, quantity: 4)
      create(:fulfilled_order_item, order: orders[2], item: @item_8, quantity: 4)
      create(:fulfilled_order_item, order: orders[3], item: @item_8, quantity: 7)
      create(:fulfilled_order_item, order: orders[3], item: @item_A, quantity: 7)
      create(:fulfilled_order_item, order: orders[4], item: @item_3, quantity: 3)
      create(:fulfilled_order_item, order: orders[4], item: @item_2, quantity: 3)
      create(:fulfilled_order_item, order: orders[4], item: @item_8, quantity: 3)

      visit items_path
      within('#stats') do
        within('#popular-merchants') do
          popular = User.popular_merchants(5)
          expect(page).to have_content("#{@merchants[7].name}, ordered from #{popular[0].total_orders} times")
          expect(page).to have_content("#{@merchants[1].name}, ordered from #{popular[1].total_orders} times")
          expect(page).to have_content("#{@merchants[0].name}, ordered from #{popular[2].total_orders} times")
        end
      end
    end
    context 'merchants by speed' do
      before(:each) do
        orders = create_list(:order, 5, user: @user)
        create(:fulfilled_order_item, order: orders[0], item: @item_1)
        create(:fulfilled_order_item, created_at: 3.seconds.ago, order: orders[0], item: @item_3)
        create(:fulfilled_order_item, created_at: 3.minutes.ago, order: orders[0], item: @item_5)
        create(:fulfilled_order_item, created_at: 3.hours.ago, order: orders[0], item: @item_7)
        create(:fulfilled_order_item, created_at: 3.days.ago, order: orders[0], item: @item_9)
        create(:order_item, order: orders[0], item: @item_1)
      end
      it 'shows 3 merchants fastest at fulfilling orders' do
        visit items_path
        within('#stats') do
          within('#fastest-merchants') do
            expect(page).to have_content("#{@merchants[2].name} #{@merchants[4].name} #{@merchants[6].name}")
          end
        end
      end
      it 'shows 3 merchants slowest at fulfilling orders' do
        visit items_path
        within('#stats') do
          within('#slowest-merchants') do
            expect(page).to have_content("#{@merchants[0].name} #{@merchants[8].name} #{@merchants[6].name}")
          end
        end
      end
    end
  end
end