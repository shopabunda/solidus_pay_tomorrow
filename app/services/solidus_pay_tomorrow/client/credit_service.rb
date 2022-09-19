# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class CreditService < SolidusPayTomorrow::Client::BaseService
      attr_reader :order_token, :refund_reason

      REFUND_ENDPOINT = 'api/ecommerce/application/:order_token/refund'

      def initialize(order_token:, payment_method:, refund_reason:)
        @order_token = order_token
        @refund_reason = refund_reason
        super
      end

      def call
        credit
      end

      private

      def credit
        handle_errors!(HTTParty.post(uri, headers: auth_headers, body: refund_body))
      end

      def uri
        "#{api_base_url}/#{REFUND_ENDPOINT.gsub(':order_token', order_token)}"
      end

      def refund_body
        { reason: refund_reason }.to_json
      end
    end
  end
end
