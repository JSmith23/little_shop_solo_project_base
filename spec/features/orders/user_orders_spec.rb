require 'rails_helper'

RSpec.describe 'User Order pages' do
  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
    @msg_no_orders_yet = 'Sorry there are no orders yet.'
  end

  context 'admin user' do 
    context 'having order data' do
      before(:each) do
        @merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4, @item_5 = create_list(:item, 5, user: @merchant)
        
        @order_1 = create(:order, user: @user)
        create(:order_item, order: @order_1, item: @item_1)
        create(:order_item, order: @order_1, item: @item_2)
    
        @order_2 = create(:completed_order, user: @user)
        create(:fulfilled_order_item, order: @order_2, item: @item_2)
        create(:fulfilled_order_item, order: @order_2, item: @item_3)
    
        @order_3 = create(:cancelled_order, user: @user)
        create(:order_item, order: @order_3, item: @item_3)
        create(:order_item, order: @order_3, item: @item_4)
    
        @order_4 = create(:disabled_order, user: @user)
        create(:order_item, order: @order_4, item: @item_1)
        create(:order_item, order: @order_4, item: @item_3)
    
      end
      scenario 'allows admin user to see all personal orders for a user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit user_orders_path(@user)

        within("#order-#{@order_1.id}") do
          @order_1.order_items.each do |o_item|
            within("#order-details-#{@order_1.id}") do
              expect(page).to have_content(o_item.item.name)
              expect(page).to have_content("quantity: #{o_item.quantity}")
              expect(page).to have_content("price: $#{o_item.price}")
              expect(page).to have_content("subtotal: $#{o_item.subtotal}")
            end
          end
          expect(page).to have_content("grand total: $#{@order_1.total}")
        end
      end
      it 'should not show the error message if there is order data to fetch' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4, @item_5 = create_list(:item, 5, user: merchant)
    
        visit orders_path

        expect(page).to_not have_content(@msg_no_orders_yet)
      end
    end
    it 'should show the error message if there are no orders' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit orders_path

      expect(page).to have_content(@msg_no_orders_yet)
    end
  end
  context 'registered user' do
    before(:each) do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
    it 'should show all orders when a user visits their own order page' do
      merchant = create(:merchant)
      @item_1, @item_2, @item_3, @item_4, @item_5 = create_list(:item, 5, user: merchant)

      @order_1 = create(:order, user: @user)
      create(:order_item, order: @order_1, item: @item_1)
      create(:order_item, order: @order_1, item: @item_2)
  
      @order_2 = create(:disabled_order, user: @user)
      create(:order_item, order: @order_2, item: @item_3)
  
      visit orders_path

      expect(page).to_not have_content(@msg_no_orders_yet)
      expect(page).to_not have_content(@item_3.name)

      within("#order-#{@order_1.id}") do
        @order_1.order_items.each do |o_item|
          within("#order-details-#{@order_1.id}") do
            expect(page).to have_content(o_item.item.name)
            expect(page).to have_content("quantity: #{o_item.quantity}")
            expect(page).to have_content("price: $#{o_item.price}")
            expect(page).to have_content("subtotal: $#{o_item.subtotal}")
          end
        end
      end
      expect(page).to have_content("grand total: $#{@order_1.total}")
    end
    it 'should show all orders when a user visits their own order page' do
      visit orders_path

      expect(page).to have_content(@msg_no_orders_yet)
    end
  end
end