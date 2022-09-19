# frozen_string_literal: true

module SolidusPayTomorrow
  class Gateway
    def initialize(options = {}); end

    def authorize
      not_implemented(__method__)
    end

    def purchase
      not_implemented(__method__)
    end

    def capture(_amount, response_code, gateway_options)
      capture_response = SolidusPayTomorrow::Client::CaptureService.call(
        order_token: response_code,
        payment_method: gateway_options[:originator].payment_method
      )
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction Captured', capture_response,
        'authorization': response_code
      )
    rescue StandardError => e
      failed_response(e)
    end

    def void
      not_implemented(__method__)
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
