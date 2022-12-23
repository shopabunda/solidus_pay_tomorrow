# frozen_string_literal: true

module SolidusPayTomorrow
  module Api
    class WebhooksController < BaseController
      skip_before_action :authenticate_user
      skip_before_action :verify_authenticity_token
      before_action :verify_pay_tomorrow_request

      def notify
        SolidusPayTomorrow::Handlers::NotifyHandler.call(params)
        return_ok("Handled!")
      end

      private

      # We don't get any unique key to identify PayTomorrow webhooks, so we check if order is in our system
      # and proceed if it is, otherwise return
      def verify_pay_tomorrow_request
        return if payment.present?

        return_ok("Couldn't find payment with uuid: #{params[:uuid]}")
      end

      def payment
        @payment = Spree::Payment.find_by(response_code: params[:uuid])
      end

      # We return 200 in all cases because PayTomorrow retries requests
      def return_ok(message)
        render json: { message: message }, status: :ok
      end
    end
  end
end
