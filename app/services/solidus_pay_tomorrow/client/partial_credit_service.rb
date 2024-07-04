# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class PartialCreditService < SolidusPayTomorrow::Client::BaseService
      attr_reader :refund, :payment

      PARTIAL_REFUND_ENDPOINT = 'api/ecommerce/application/:order_token/partial/refund'

      def initialize(refund:, payment_method:)
        @refund = refund
        @payment = refund.payment
        super
      end

      def call
        partial_credit
      end

      private

      # Either take last saved application token from refunds or the original order token
      def order_token
        payment.refunds.where.not(transaction_id: nil).last&.transaction_id || payment.response_code
      end

      def partial_credit
        handle_errors!(HTTParty.post(uri, headers: auth_headers, body: partial_refund_body.to_json))
      end

      def uri
        "#{api_base_url}/#{PARTIAL_REFUND_ENDPOINT.gsub(':order_token', order_token)}"
      end

      # Note: The way partial refunds work in PT is -
      # When a partial refund is created, PT actually refunds the whole
      # loan amount that is authorized during capture,
      # and a new loan is created for partial refund loanAmount
      # Hence, the refund that we create is of
      # loan_amount = available credit - refund amount
      # Eg: Order total = 1000
      # Refund 1 = 50 => creates a new loan for 1000-50=950
      # Refund 2 = 100 => creates a new loan for 950-100=850
      def partial_refund_body
        { loanAmount: payment.credit_allowed - refund.amount,
          items: items }
      end

      def items
        payment.order.line_items.map do |line_item|
          { description: line_item.description,
            quantity: line_item.quantity,
            price: line_item.price.to_f }
        end
      end
    end
  end
end
