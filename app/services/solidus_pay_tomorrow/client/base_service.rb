# frozen_string_literal: true

require 'httparty'

module SolidusPayTomorrow
  module Client
    class BaseService
      attr_reader :payment_method

      STAGING_URL = 'https://api-staging.paytomorrow.com'
      PRODUCTION_URL = 'https://api.paytomorrow.com'
      AUTH_ENDPOINT = 'api/uaa/oauth/token'

      def initialize(payment_method:, **_args)
        @payment_method = payment_method
      end

      class << self
        attr_accessor :current_token

        def call(*args, **kwargs, &block)
          new(*args, **kwargs, &block).call
        end
      end

      def valid_token
        new_token if current_token_invalid?
        self.class.current_token[:access_token]
      end

      private

      def api_base_url
        if payment_method.preferred_test_mode
          STAGING_URL
        else
          PRODUCTION_URL
        end
      end

      def auth_headers
        { 'Authorization': "Bearer #{valid_token}",
          'Content-Type': 'application/json' }
      end

      def handle_errors!(result)
        return result.parsed_response if result.success?

        raise StandardError, "#{result.parsed_response['error']}: #{result.parsed_response['errorDetails']}"
      end

      def new_token
        result = handle_errors!(HTTParty.post(token_uri, headers: token_headers, body: URI.encode_www_form(token_body)))
        self.class.current_token =
          { expires_at: Time.zone.now + result['expires_in'].seconds }.merge!(result.symbolize_keys)
      end

      # Tokens are valid for 10-12 hours, if they are near expiry, get new token
      def current_token_invalid?
        self.class.current_token.nil? || Time.zone.now > self.class.current_token[:expires_at] - 10.minutes
      end

      def token_uri
        "#{api_base_url}/#{AUTH_ENDPOINT}"
      end

      def token_headers
        { 'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Basic #{payment_method.preferences[:signature]}" }
      end

      def token_body
        { grant_type: 'password',
          scope: 'openid',
          username: payment_method.preferences[:username],
          password: payment_method.preferences[:password] }
      end
    end
  end
end
