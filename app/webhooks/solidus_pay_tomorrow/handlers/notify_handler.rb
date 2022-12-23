# frozen_string_literal: true

module SolidusPayTomorrow
  module Handlers
    class NotifyHandler
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def self.call(params)
        new(params).call
      end

      def call
        case params[:payment_status]
        when 'pending'
          SolidusPayTomorrow::Handlers::SuccessHandler.call(order, payment)
          # There is no need to handle other callbacks right now, if needed,
          # add here
        end
      end

      private

      def payment
        @payment ||= Spree::Payment.find_by(response_code: params[:uuid])
      end

      def order
        @order || payment.order
      end
    end
  end
end
