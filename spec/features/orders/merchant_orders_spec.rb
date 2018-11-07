require 'rails_helper'

RSpec.describe 'Merchant Orders' do 
  before(:each) do
    @user = create(:user)
    @merchant = create(:merchant)
    @item_1, @item_2, @item_3, @item_4, @item_5 = create_list(:item, 5, user: @merchant)
    
    @order_1 = create(:order, user: @user)
    create(:order_item, order: @order_1, item: @item_1)
    create(:order_item, order: @order_1, item: @item_2)

    @order_2 = create(:completed_order, user: @user)
    create(:fulfilled_order_item, order: @order_2, item: @item_2)
    create(:fulfilled_order_item, order: @order_2, item: @item_3)

    @admin = create(:admin)
  end

  context 'merchant user' do 
    it 'sees a link to view dashboard orders if there are any orders' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_path 
 
      click_link("Merchant Orders")
      
      expect(current_path).to eq(dashboard_orders_path)
    end
    it 'does not see a link to view dashboard orders if there are no orders' do 
      merchant_2 = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_2)

      visit dashboard_path 
      
      expect(page).to_not have_link("Merchant Orders")
    end
    it 'can display orders containing items sold by that merchant' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_orders_path

      expect(page).to have_content(@user.email)
      expect(page).to have_content("Order #{@order_1.id}")
      expect(page).to_not have_content("Order #{@order_2.id}")
    end
    it 'displays data for an order when viewing the order show page' do
      merchant_1, merchant_2 = create_list(:merchant, 2)
      item_1, item_2 = create_list(:item, 2, user: merchant_1)
      item_2.update(user: merchant_2)
      order_1 = create(:order, user: @user)
      oi_1 = create(:order_item, order: order_1, item: item_1)
      oi_2 = create(:order_item, order: order_1, item: item_2)
  
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_1)
      visit dashboard_orders_path

      click_on "Order #{order_1.id}"
      expect(current_path).to eq(order_path(order_1))

      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.address)
      expect(page).to have_content(@user.city)
      expect(page).to have_content(@user.state)
      expect(page).to have_content(@user.zip)

      expect(page).to_not have_content(item_2.name)
      old_inventory = item_1.inventory
      within "#orderitem-details-#{oi_1.id}" do
        expect(page).to have_content(item_1.name)
        click_button "fulfill item"
      end

      expect(current_path).to eq(order_path(order_1))
      expect(page).to have_content("Item fulfilled, good job on the sale!")
      within "#orderitem-details-#{oi_1.id}" do
        expect(page).to have_content("item fulfilled")
      end
      item_check = Item.find(item_1.id)
      expect(item_check.inventory).to_not eq(old_inventory)
      expect(old_inventory - item_check.inventory).to eq(oi_1.quantity)
    end
    it 'blocks me from fulfilling an order if I do not have enough inventory' do 
      merchant_1 = create(:merchant)
      item_1, item_2 = create_list(:item, 2, user: merchant_1)
      order_1 = create(:order, user: @user)
      oi_1 = create(:order_item, quantity: 100, order: order_1, item: item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_1)

      visit order_path(order_1)

      within "#orderitem-details-#{oi_1.id}" do
        expect(page).to have_content("cannot fulfill, not enough inventory")
      end
    end
  end

  context 'admin user' do
    it 'sees a link to edit merchant profile data' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit merchant_path(@merchant) 
 
      click_link "Edit Profile Data"
      expect(current_path).to eq(edit_user_path(@merchant))
    end
    it 'sees a link to view dashboard orders if there are any orders' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit merchant_path(@merchant) 
      click_link("Merchant Orders")

      expect(current_path).to eq(merchant_orders_path(@merchant))
      expect(page).to have_content(@user.email)
      expect(page).to have_content("Order #{@order_1.id}")
      expect(page).to have_content("Order #{@order_2.id}")
    end
  end
end