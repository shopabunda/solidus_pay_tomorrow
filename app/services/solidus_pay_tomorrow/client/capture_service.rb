# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class CaptureService < SolidusPayTomorrow::Client::BaseService
      attr_reader :order_token

      SETTLE_ENDPOINT = '/api/ecommerce/application/:order_token/settle'

      def initialize(order_token:, payment_method:)
        @order_token = order_token
        super
      end

      def call
        capture
      end

      private

      def capture
        handle_errors!(HTTParty.post(uri, headers: auth_headers))
      end

      def uri
        "#{api_base_url}#{SETTLE_ENDPOINT.gsub(':order_token', order_token)}"
      end
    end
  end
end
