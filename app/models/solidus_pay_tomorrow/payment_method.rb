# frozen_string_literal: true

module SolidusPayTomorrow
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    preference :username, :string
    preference :password, :string

    def gateway_class
      ::SolidusPayTomorrow::Gateway
    end

    def payment_source_class
      ::SolidusPayTomorrow::PaymentSource
    end

    def partial_name
      'pt'
    end
  end
end
