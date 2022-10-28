# frozen_string_literal: true

module SolidusPayTomorrow
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    preference :username, :string
    preference :password, :string
    preference :signature, :string

    # If a payment has one of these states, then it can't be voided
    # on PayTomorrow
    NOT_VOIDABLE_STATES = %w[completed invalid void].freeze

    def gateway_class
      ::SolidusPayTomorrow::Gateway
    end

    def payment_source_class
      ::SolidusPayTomorrow::PaymentSource
    end

    def partial_name
      'pay_tomorrow'
    end
  end
end
