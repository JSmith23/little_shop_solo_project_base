require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'Relationships' do
    it { should belong_to(:user) }
    it { should have_many(:order_items) }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'Validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'Class Methods' do
    it '.popular_items(quantity)' do
      user = create(:user)
      merchants = create_list(:merchant, 2)
      item_1 = create(:item, user: merchants[0])
      item_2 = create(:item, user: merchants[0])
      item_3 = create(:item, user: merchants[1])
      item_4 = create(:item, user: merchants[1])
      orders = create_list(:completed_order, 2, user: user)
      create(:fulfilled_order_item, quantity: 10, item: item_1, order: orders[0])
      create(:fulfilled_order_item, quantity: 20, item: item_2, order: orders[0])
      create(:fulfilled_order_item, quantity: 40, item: item_3, order: orders[1])
      create(:fulfilled_order_item, quantity: 30, item: item_4, order: orders[1])

      expect(Item.popular_items(3)).to eq([item_3, item_4, item_2])
    end
  end

  describe 'Instance Methods' do
  end
end
