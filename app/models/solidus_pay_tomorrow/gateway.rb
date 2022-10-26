# frozen_string_literal: true

module SolidusPayTomorrow
  class Gateway
    def initialize(options = {}); end

    def authorize
      not_implemented(__method__)
    end

    # The authorize step happens while checking out in PayTomorrow.
    # Hence purchase just calls capture
    def purchase(amount, payment_source, gateway_options)
      capture(amount, payment_source.application_token, gateway_options)
    end

    def capture(_amount, response_code, gateway_options)
      capture_response = SolidusPayTomorrow::Client::CaptureService.call(
        order_token: response_code,
        payment_method: gateway_options[:originator].payment_method
      )
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction Captured', capture_response,
        authorization: response_code
      )
    rescue StandardError => e
      failed_response(e)
    end

    def void(response_code, gateway_options)
      void_response = SolidusPayTomorrow::Client::VoidService.call(
        order_token: response_code,
        payment_method: gateway_options[:originator].payment_method
      )
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction Void', void_response,
        authorization: response_code
      )
    rescue StandardError => e
      failed_response(e)
    end

    def credit
      not_implemented(__method__)
    end

    private

    # Remove this once all methods are implemented
    def not_implemented(method_name)
      raise NotImplementedError, "#{method_name} method has not been implemented in #{self.class} class"
    end

    def failed_response(error)
      ActiveMerchant::Billing::Response.new(false, error, {})
    end
  end
end
