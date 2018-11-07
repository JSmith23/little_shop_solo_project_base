FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |n| "user_#{n}@gmail.com" }
    sequence(:password) { |n| "Password #{n}" }
    sequence(:name) { |n| "User #{n}" }
    sequence(:slug) { |n| "slug_#{n}" }
    sequence(:address) { |n| "Address #{n}" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:zip) { |n| "Zip #{n}" }
    role { 0 }
    active { true }
  end
  factory :inactive_user, parent: :user do
    sequence(:email) { |n| "inactive_user_#{n}@gmail.com" }
    role { 0 }
    active { false }
  end

  factory :merchant, parent: :user do
    sequence(:email) { |n| "merchant_#{n}@gmail.com" }
    sequence(:name) { |n| "Merchant #{n}" }
    role { 1 }
    active { true }
  end
  factory :inactive_merchant, parent: :user do
    sequence(:email) { |n| "inactive_merchant_#{n}@gmail.com" }
    sequence(:name) { |n| "Merchant #{n}" }
    role { 1 }
    active { false }
  end

  factory :admin, parent: :user do
    sequence(:email) { |n| "admin_#{n}@gmail.com" }
    sequence(:name) { |n| "Admin #{n}" }
    role { 2 }
    active { true }
  end
end
