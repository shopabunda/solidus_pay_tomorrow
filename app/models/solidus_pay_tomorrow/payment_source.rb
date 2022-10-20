# frozen_string_literal: true

require_dependency 'solidus_pay_tomorrow'

module SolidusPayTomorrow
  class PaymentSource < Spree::PaymentSource
    validates :payment_method_id, presence: true
  end
end
