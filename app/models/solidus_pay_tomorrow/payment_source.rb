# frozen_string_literal: true

require_dependency 'solidus_pay_tomorrow'

module SolidusPayTomorrow
  class PaymentSource < Spree::PaymentSource
    validates :payment_method_id, presence: true

    def can_void?(payment)
      if SolidusPayTomorrow::PaymentMethod::NOT_VOIDABLE_STATES.include?(payment.state)
        return false
      end

      true
    end
  end
end
