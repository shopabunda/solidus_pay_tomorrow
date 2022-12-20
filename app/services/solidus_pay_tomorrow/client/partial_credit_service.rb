# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class PartialCreditService < SolidusPayTomorrow::Client::BaseService
      attr_reader :refund

      PARTIAL_REFUND_ENDPOINT = 'api/ecommerce/application/:order_token/partial/refund'

      def initialize(refund:, payment_method:)
        @refund = refund
        super
      end

      def call
        partial_credit
      end

      private

      def order_token
        refund.payment.response_code
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
      # payment's loan amount - refund amount to actually only refund
      # refund.amount
      def partial_refund_body
        { loanAmount: refund.payment.amount - refund.amount,
          items: items }
      end

      def items
        refund.payment.order.line_items.map do |line_item|
          { description: line_item.description,
            quantity: line_item.quantity,
            price: line_item.price.to_f }
        end
      end
    end
  end
end
