require 'rails_helper'

RSpec.describe 'Merchant Leader boards' do
  context 'as any user' do
    describe 'top by items quantity' do
      let!(:this_month_merchants) do
        # NOTE: it creates and item for each merchant and creates an order for each items
        # so that the index + 1 is quantity of that item in the order
        # so in result we have 15 merchants with 15, 14, ..., 1 items sold
        create_list(:merchant, 15).each_with_index do |merchant, i|
          item = create(:item, user: merchant)
          order = create(:completed_order, user: merchant)
          create(:fulfilled_order_item, order: order, item: item, quantity: i + 1)
        end.reverse
      end

      let!(:prev_month_merchants) do
        create_list(:merchant, 5).each_with_index do |merchant, i|
          item = create(:item, user: merchant)
          order = create(:completed_order, user: merchant, created_at: 2.months.ago)
          create(:fulfilled_order_item, order: order, item: item, quantity: i * 100)
        end.reverse
      end

      it 'shows top 10 Merchants who sold the most items in the past month' do
        visit merchants_path
        within '#most_sold' do
          expect(page).to have_content('Merchants who sold the most items in the past month')
          items = page.all('li')
          expect(items.count).to eq(10)
          items.each_with_index do |item, i|
            expect(item.text).to eq(this_month_merchants[i].name)
          end
        end
      end
    end

    describe 'top by fulfilled orders amount' do
      let!(:this_month_merchants) do
        create_list(:merchant, 15).each_with_index do |merchant, i|
          item = create(:item, user: merchant)
          create_list(:completed_order, i + 1, user: merchant).each do |order|
            create(:fulfilled_order_item, order: order, item: item, quantity: 1)
          end
        end.reverse
      end

      let!(:prev_month_merchants) do
        create_list(:merchant, 5).each_with_index do |merchant, i|
          item = create(:item, user: merchant)
          create_list(:completed_order, i * 100, user: merchant, created_at: 2.months.ago).each do |order|
            create(:fulfilled_order_item, order: order, item: item, quantity: 1)
          end
        end.reverse
      end

      it 'shows top 10 Merchants who fulfilled non-cancelled orders in the past month' do
        visit merchants_path
        within '#most_fulfilled' do
          expect(page).to have_content('Merchants who fulfilled non-cancelled orders in the past month')
          items = page.all('li')
          expect(items.count).to eq(10)
          items.each_with_index do |item, i|
            expect(item.text).to eq(this_month_merchants[i].name)
          end
        end
      end
    end
  end

  context 'as loggined user' do
    let(:state) { "Foobar State" }
    let(:city) { "Foobar City" }
    let!(:current_user) { create(:user, state: state, city: city) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
    end

    let!(:fastest_in_this_city) do
      user = create(:user, city: city)
      create_list(:merchant, 10).each_with_index do |merchant, i|
        item = create(:item, user: merchant)
        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: item, quantity: 1, updated_at: ((i + 1) * 100).days.since)
      end
    end

    let!(:fastest_in_this_state) do
      user = create(:user, state: state)
      create_list(:merchant, 10).each_with_index do |merchant, i|
        item = create(:item, user: merchant)
        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: item, quantity: 1, updated_at: ((i + 1) * 10).days.since)
      end
    end

    let!(:fastest_globaly) do
      user = create(:user)
      create_list(:merchant, 10).each_with_index do |merchant, i|
        item = create(:item, user: merchant)
        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: item, quantity: 1, updated_at: (i + 1).days.since)
      end
    end

    describe 'top fastest in state' do
      it "shows top 5 merchants who have fulfilled items the fastest to user's state" do
        visit merchants_path
        within '#fastest_fulfilled_in_state' do
          expect(page).to have_content('Merchants who have fulfilled items the fastest to your state')
          items = page.all('li')
          expect(items.count).to eq(5)
          items.each_with_index do |item, i|
            expect(item.text).to eq(fastest_in_this_state[i].name)
          end
        end
      end
    end

    describe 'top fastest in city' do
      it "shows see top 5 merchants who have fulfilled items the fastest to user's city" do
        visit merchants_path
        within '#fastest_fulfilled_in_city' do
          expect(page).to have_content('Merchants who have fulfilled items the fastest to your city')
          items = page.all('li')
          expect(items.count).to eq(5)
          items.each_with_index do |item, i|
            expect(item.text).to eq(fastest_in_this_city[i].name)
          end
        end
      end
    end
  end
end
