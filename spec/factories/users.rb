FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    deleted false
    last_sign_in_at 1.month.ago
    sequence :email do |n|
      "user#{n}@mail.com"
    end
    device_type :android
    sequence :device_id do |n|
      "device id #{n}"
    end
    sequence :phone do |n|
      "+336%08i" % n
    end

    sms_code '098765'
    validation_status "validated"

    sequence :token do |n|
      "foobar#{n}"
    end

    community do
      $server_community.slug
    end

    trait :public do
      user_type 'public'
    end

    trait :pro do
      organization
      user_type 'pro'
    end

    trait :partner do
      partner { create :partner }
    end

    trait :admin do
      first_name 'pouet'
      email 'guillaume@entourage.social'
      phone '+33768037348'
      organization
      user_type 'pro'
      admin true
    end

    factory :pro_user,    traits: [:pro]
    factory :public_user, traits: [:public]
    factory :partner_user, traits: [:public, :partner]
    factory :admin_user,  traits: [:admin]
  end
end
