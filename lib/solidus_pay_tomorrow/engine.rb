# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusPayTomorrow
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_pay_tomorrow'

    initializer 'solidus_pay_tomorrow.add_static_preference', after: 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << 'SolidusPayTomorrow::PaymentMethod'
      app.config.to_prepare do
        Spree::Config.static_model_preferences.add(
          SolidusPayTomorrow::PaymentMethod,
          'pt_credentials', {
            username: ENV['PAY_TOMORROW_USERNAME'],
            password: ENV['PAY_TOMORROW_PASSWORD'],
            signature: ENV['PAY_TOMORROW_SIGNATURE']
          }
        )
      end
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
