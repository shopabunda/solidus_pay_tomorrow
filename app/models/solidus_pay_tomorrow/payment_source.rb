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

    # PayTomorrow orders can only process a single refund (partial or full)
    # Hence don't show option for refund if there's already an existing refund
    def can_credit?(payment)
      return false if payment.refunds.exists?

      return true if payment.state == 'completed'

      false
    end
  end
end
