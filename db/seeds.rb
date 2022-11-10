# frozen_string_literal: true

if ENV['PAY_TOMORROW_USERNAME'] && ENV['PAY_TOMORROW_PASSWORD'] && ENV['PAY_TOMORROW_SIGNATURE'] &&
  SolidusPayTomorrow::PaymentMethod.count == 0
  SolidusPayTomorrow::PaymentMethod.create!(
    type: 'SolidusPayTomorrow::PaymentMethod',
    name: 'PayTomorrow',
    preference_source: 'pt_credentials',
    active: true
  )
end
