require 'rails_helper'

RSpec.describe Cart do
  it '.total_count' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })
    expect(cart.total_count).to eq(5)
  end

  it '.add_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.add_item(1)
    cart.add_item(2)

    expect(cart.contents).to eq({
      '1' => 3,
      '2' => 4
      })
  end

  it '.remove_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_item(1)
    cart.remove_item(2)

    expect(cart.contents).to eq({
      '1' => 1,
      '2' => 2
      })
  end

  it '.remove_item removes last' do
    cart = Cart.new({
      '1' => 1,
      '2' => 3
    })

    cart.remove_item(1)

    expect(cart.contents).to eq({
      '2' => 3
      })
  end

  it '.remove_all_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_all_item(1)

    expect(cart.contents).to eq({
      '2' => 3
      })
  end

  it '.count_of' do
    cart = Cart.new({})
    expect(cart.count_of(5)).to eq(0)
  end

  it '.grand_total' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.grand_total).to eq(item_1.price+item_2.price+item_2.price)
  end
end
