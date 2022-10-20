# frozen_string_literal: true

FactoryBot.define do
  factory :pt_payment_method, class: SolidusPayTomorrow::PaymentMethod do
    name { 'PayTomorrow' }
  end

  factory :pt_payment_source, class: SolidusPayTomorrow::PaymentSource do
    payment_method
    application_token { 'order-token' }
  end
end
