# frozen_string_literal: true

FactoryBot.define do
  factory :pt_payment_method, class: SolidusPayTomorrow::PaymentMethod do
    name { 'PayTomorrow' }
  end
end
