# frozen_string_literal: true

module SolidusPayTomorrow
  module Api
    class CreateOrderController < BaseController
      def create
        payment_method = SolidusPayTomorrow::PaymentMethod.find(permitted_params[:payment_method])
        @result = SolidusPayTomorrow::Client::CreateOrderService.call(order: @order, payment_method: payment_method)
        @successfully_created = @result.key?('url') && @result.key?('token')
        render json: @result, status: :created if @successfully_created
      end

      private

      def permitted_params
        params.permit(:order_number, :payment_method)
      end
    end
  end
end
