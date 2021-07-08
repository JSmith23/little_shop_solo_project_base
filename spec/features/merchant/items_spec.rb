require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Items' do
  context 'as a merchant' do
    before(:each) do
      @merchant = create(:merchant)
    end
    describe 'when I visit /dashboard' do
      it 'should show me a link to see my items for sale' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_path

        click_link 'My Items for Sale'

        expect(current_path).to eq(dashboard_items_path)
      end
    end
    describe 'when I visit my items page' do
      it 'should show all information about my items' do
        item_1, item_2 = create_list(:item, 2, user: @merchant)
        item_3 = create(:inactive_item, user: @merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_items_path

        within "#item-#{item_1.id}" do
          expect(page).to have_content("ID: #{item_1.id}")
          expect(page).to have_content(item_1.name)
          # code smell, had to hard-code an ID in the image filename for factorybot sequence
          expect(page.find("#item-image-#{item_1.id}")['src']).to have_content(item_1.image)
          expect(page).to have_content("Price: #{number_to_currency(item_1.price)}")
          expect(page).to have_content("Inventory: #{item_1.inventory}")
          expect(page).to have_link("Edit Item")
          expect(page).to have_button("Disable Item")
        end
        within "#item-#{item_3.id}" do
          expect(page).to have_button("Enable Item")
        end
      end
      it 'should allow me to disable active items' do
        item_1 = create(:item, user: @merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_items_path

        within "#item-#{item_1.id}" do
          click_button "Disable Item"
        end
        expect(page).to have_content("Item #{item_1.id} is now disabled")

        within "#item-#{item_1.id}" do
          expect(page).to_not have_button("Disable Item")
          expect(page).to have_button("Enable Item")
        end
      end
      it 'should allow me to enable inactive items' do
        item_1 = create(:inactive_item, user: @merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_items_path

        within "#item-#{item_1.id}" do
          click_button "Enable Item"
        end
        expect(page).to have_content("Item #{item_1.id} is now enabled")

        within "#item-#{item_1.id}" do
          expect(page).to have_button("Disable Item")
          expect(page).to_not have_button("Enable Item")
        end
      end

      it 'should allow me to add a new item with slug' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:admin))
        visit dashboard_items_path
        click_link "Add New Item"

        fill_in :item_name, with: 'New Item Name'
        fill_in :item_slug, with: 'new-item-name'
        fill_in :item_description, with: 'hottest item of 2018'
        fill_in :item_image, with: 'new-image.jpg'
        fill_in :item_price, with: 5
        fill_in :item_inventory, with: 100
        click_button 'Create Item'

        item = Item.last
        within "#item-#{item.id}" do
          expect(item.slug).to eq('new-item-name')
          expect(page).to have_content("ID: #{item.id}")
          expect(page).to have_content(item.name)
          expect(page.find("#item-image-#{item.id}")['src']).to have_content(item.image)
          expect(page).to have_content("Price: #{number_to_currency(item.price)}")
          expect(page).to have_content("Inventory: #{item.inventory}")
          expect(page).to have_link("Edit Item")
          # disabled by default
          expect(page).to have_button("Disable Item")
        end
      end

      it 'should allow me to add a new item' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_items_path
        click_link "Add New Item"

        fill_in :item_name, with: 'New Item Name'
        fill_in :item_description, with: 'hottest item of 2018'
        fill_in :item_image, with: 'new-image.jpg'
        fill_in :item_price, with: 5
        fill_in :item_inventory, with: 100
        click_button 'Create Item'

        expect(page).to have_no_selector('#item_slug')
        expect(current_path).to eq dashboard_items_path
        item = Item.last
        within "#item-#{item.id}" do
          expect(page).to have_content("ID: #{item.id}")
          expect(page).to have_content(item.name)
          expect(page.find("#item-image-#{item.id}")['src']).to have_content(item.image)
          expect(page).to have_content("Price: #{number_to_currency(item.price)}")
          expect(page).to have_content("Inventory: #{item.inventory}")
          expect(page).to have_link("Edit Item")
          # disabled by default
          expect(page).to have_button("Disable Item")
        end
      end
      it 'should allow me to add a new item with a placeholder image' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_items_path
        click_link "Add New Item"

        fill_in :item_name, with: 'New Item Name'
        fill_in :item_description, with: 'hottest item of 2018'
        fill_in :item_price, with: 5
        fill_in :item_inventory, with: 100
        click_button 'Create Item'

        expect(current_path).to eq dashboard_items_path
        item = Item.last
        within "#item-#{item.id}" do
          expect(page.find("#item-image-#{item.id}")['src']).to have_content('https://picsum.photos/200/300/?image=0&blur=true')
        end
      end
      it 'should block me from adding a new item if form is blank' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_items_path
        click_link "Add New Item"
        click_button 'Create Item' # no data submitted
        expect(current_path).to eq(merchant_items_path(@merchant))
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Description can't be blank")
        expect(page).to have_content("Price can't be blank")
        expect(page).to have_content("Price is not a number")
        expect(page).to have_content("Inventory can't be blank")
        expect(page).to have_content("Inventory is not a number")
      end
      it 'should allow me to edit a new item' do
        item = create(:item, user: @merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_items_path
        within "#item-#{item.id}" do
          click_link "Edit Item"
        end

        fill_in :item_name, with: 'New Item Name'
        fill_in :item_description, with: 'hottest item of 2018'
        fill_in :item_image, with: 'new-image.jpg'
        fill_in :item_price, with: 5
        fill_in :item_inventory, with: 100
        click_button 'Update Item'

        expect(current_path).to eq dashboard_items_path
        item = Item.find(item.id) # fetch from db
        within "#item-#{item.id}" do
          expect(page).to have_content('New Item Name')
          expect(page.find("#item-image-#{item.id}")['src']).to have_content('new-image.jpg')
          expect(page).to have_content("Price: #{number_to_currency(5)}")
          expect(page).to have_content("Inventory: 100")
        end
      end
      it 'should block me from editing a new item if require fields are blank' do
        item = create(:item, user: @merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_items_path
        within "#item-#{item.id}" do
          click_link "Edit Item"
        end
        fill_in :item_name, with: ''
        fill_in :item_description, with: ''
        fill_in :item_price, with: ''
        fill_in :item_inventory, with: ''
        click_button 'Update Item'

        expect(current_path).to eq(merchant_item_path(@merchant, item))
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Description can't be blank")
        expect(page).to have_content("Price can't be blank")
        expect(page).to have_content("Price is not a number")
        expect(page).to have_content("Inventory can't be blank")
        expect(page).to have_content("Inventory is not a number")
      end
    end
  end
end
