require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Items Index' do
  context 'as a user' do
    before(:each) do
      @merchant = create(:merchant)
      @active_item = create(:item, user: @merchant)
      @inactive_item = create(:inactive_item, name: 'inactive item 1')
      @user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
    describe 'visiting /items' do
      it 'should show all active items' do
        visit items_path

        expect(page).to_not have_content(@inactive_item.name)

        within "#item-#{@active_item.id}" do
          expect(page).to have_content("Merchant: #{@active_item.user.name}")
          expect(page).to have_content(@active_item.name)
          # code smell, had to hard-code an ID in the image filename for factorybot sequence
          expect(page.find("#item-image-#{@active_item.id}")['src']).to have_content "https://picsum.photos/200/300?image=1"
          expect(page).to have_content("Price: #{number_to_currency(@active_item.price)}")
          expect(page).to have_content("Inventory: #{@active_item.inventory}")

          click_link @active_item.name
        end
        expect(current_path).to eq(item_path(id: @active_item.slug))

        visit items_path

        within "#item-#{@active_item.id}" do
          find(:xpath, "//a/img[@alt='image for #{@active_item.name}']/..").click
        end
        expect(current_path).to eq(item_path(id: @active_item.slug))
      end
    end
    describe 'visiting /items/:id' do
      it 'should show all item content plus a button to add to cart' do
        visit item_path(@active_item.path_keys)

        expect(page).to have_content("Merchant: #{@active_item.user.name}")
        expect(page).to have_content(@active_item.name)
        # code smell, had to hard-code an ID in the image filename for factorybot sequence
        expect(page.find("#item-image-#{@active_item.id}")['src']).to have_content "https://picsum.photos/200/300?image=1"
        expect(page).to have_content("Price: #{@active_item.price}")
        expect(page).to have_content("Inventory: #{@active_item.inventory}")

        expect(page).to have_button("Add to Cart")
      end
    end
    describe 'add item to cart' do
      it 'should show all item content plus a button to add to cart' do
        visit item_path(@active_item)
        expect(page).to have_content("Cart: 0")
        click_button("Add to Cart")
        expect(page).to have_content("Cart: 1")
        expect(page).to have_content("Added another #{@active_item.name} to your cart")
      end
    end
    describe 'visiting /cart' do
      it 'should show all item content for what is in my cart' do
        FactoryBot.reload
        item_1, item_2 = create_list(:item, 2, user: @merchant)

        visit item_path(item_1)
        click_button("Add to Cart")
        visit item_path(item_2)
        click_button("Add to Cart")
        click_button("Add to Cart")

        visit carts_path
        within "#item-#{item_1.id}" do
          expect(page).to have_content("Merchant: #{item_1.user.name}")
          expect(page).to have_content(item_1.name)
          # code smell, had to hard-code an ID in the image filename for factorybot sequence
          expect(page.find("#item-image-#{item_1.id}")['src']).to have_content "https://picsum.photos/200/300?image=1"
          expect(page).to have_content("Price: #{item_1.price}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: $#{item_1.price}")
        end
        within "#item-#{item_2.id}" do
          expect(page).to have_content("Price: #{item_2.price}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal: $#{2 * item_2.price}")
        end
        expect(page).to have_content("Grand Total: $12.00")
        click_button "Check out"
      end
      it 'should allow me to empty my cart' do
        FactoryBot.reload
        item_1, item_2 = create_list(:item, 2, user: @merchant)

        visit item_path(item_1)
        click_button("Add to Cart")
        click_button("Add to Cart")
        visit item_path(item_2)
        click_button("Add to Cart")
        click_button("Add to Cart")

        visit carts_path
        expect(page).to have_content("Cart: 4")
        click_button "Empty Cart"
        expect(page).to have_content("Cart: 0")
      end
      it 'should block me from adding more items than a merchant has quantity' do
        FactoryBot.reload
        item_1 = create(:item, user: @merchant)
        visit item_path(item_1)
        click_button("Add to Cart")
        visit carts_path
        item_1.inventory.times do |num|
          click_button("Add 1")
        end
        expect(page).to have_content("Cannot add another #{item_1.name} to your cart, merchant doesn't have enough inventory")
      end
      it 'should allow me to change item quantities in my cart' do
        FactoryBot.reload
        item_1, item_2 = create_list(:item, 2, user: @merchant)

        visit item_path(item_1)
        click_button("Add to Cart")
        expect(page).to have_content("Cart: 1")

        visit carts_path
        expect(page).to have_content("Grand Total: $3.00")
        within "#item-#{item_1.id}" do
          expect(page).to have_content("Quantity: 1")
          click_button "Add 1"
        end

        expect(page).to have_content("Added another #{item_1.name} to your cart")
        expect(page).to have_content("Cart: 2")
        visit carts_path
        within "#item-#{item_1.id}" do
          expect(page).to have_content("Quantity: 2")
        end
        expect(page).to have_content("Grand Total: $6.00")
        within "#item-#{item_1.id}" do
          click_button "Remove 1"
        end
        expect(page).to have_content("Removed #{item_1.name} from your cart")

        expect(page).to have_content("Grand Total: $3.00")
        within "#item-#{item_1.id}" do
          expect(page).to have_content("Quantity: 1")
          click_button "Remove All"
        end

        expect(page).to have_content("Removed entire quantity of #{item_1.name} from your cart")
        expect(page).to have_content("Cart: 0")
        expect(page).to have_content("Grand Total: $0.00")
      end
    end
  end
  context 'as a visitor' do
    it 'should tell me to login/register if I am a visitor' do
      @merchant = create(:merchant)
      FactoryBot.reload
      item_1, item_2 = create_list(:item, 2, user: @merchant)

      visit item_path(item_1)
      click_button("Add to Cart")
      visit carts_path
      within('#must-log-in') do
        expect(page).to have_content("You must register or log in to complete your purchase")
        expect(page).to have_link("register")
        expect(page).to have_link("log in")
      end
    end
  end
end
