# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class VoidService < SolidusPayTomorrow::Client::BaseService
      attr_reader :order_token

      CANCEL_ENDPOINT = 'api/ecommerce/application/:order_token/cancel'

      def initialize(order_token:, payment_method:)
        @order_token = order_token
        super
      end

      def call
        void
      end

      private

      def void
        handle_errors!(HTTParty.post(uri, headers: auth_headers))
      end

      def uri
        "#{api_base_url}/#{CANCEL_ENDPOINT.gsub(':order_token', order_token)}"
      end
    end
  end
end
