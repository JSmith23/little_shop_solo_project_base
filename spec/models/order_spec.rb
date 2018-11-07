require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'Relationships' do
    it { should belong_to(:user) }
    it { should have_many(:order_items) }
    it { should have_many(:items).through(:order_items) }
  end

  describe 'Validations' do 
    it { should validate_presence_of(:status) }
  end

  describe 'Class Methods' do
    before(:each) do 
      @user_1 = create(:user, state: 'CO')
      @user_2 = create(:user, state: 'CA')
      @user_3 = create(:user, state: 'FL')
      @user_4 = create(:user, state: 'NY')

      @merchant = create(:merchant)
      item_1 = create(:item, user: @merchant)

      # Colorado is 1st place
      order = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # California is 2nd place
      order = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      # Sorry Florida
      order = create(:completed_order, user: @user_3)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_4)
      # NY is 3rd place
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: @user_4)
      create(:fulfilled_order_item, order: order, item: item_1)    end
    it '.top_shipping(:state, 3)' do 
      expect(Order.top_shipping(:state, 3)).to eq(['CO', 'CA', 'NY'])
    end  
    it '.top_buyers(3)' do 
      expect(Order.top_buyers(3)).to eq([@user_4, @user_2, @user_3])
    end
    it '.biggest_orders(3)' do
      item_1 = create(:item, user: @merchant)

      order_1 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, quantity: 100, order: order_1, item: item_1)
      
      order_2 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, quantity: 10000, order: order_2, item: item_1)

      order_3 = create(:completed_order, user: @user_1)
      create(:fulfilled_order_item, quantity: 1000, order: order_3, item: item_1)

      expect(Order.biggest_orders(3)).to eq([order_2, order_3, order_1])
    end
  end

  describe 'Instance Methods' do
    it '.total' do
      @user = create(:user)
      @merchant = create(:merchant)
      @item_1, @item_2, @item_3 = create_list(:item, 3, user: @merchant)
      
      @order_1 = create(:order, user: @user)
      oi_1 = create(:order_item, order: @order_1, item: @item_1)
      oi_2 = create(:order_item, order: @order_1, item: @item_2)
      oi_3 = create(:order_item, order: @order_1, item: @item_3)
  
      expect(@order_1.total).to eq(oi_1.subtotal + oi_2.subtotal + oi_3.subtotal)
    end
  end
end
