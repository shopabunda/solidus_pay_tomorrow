# frozen_string_literal: true

module SolidusPayTomorrow
  class HandleOrderCreationService < SolidusPayTomorrow::BaseService
    attr_reader :order, :payment_method

    def initialize(order:, payment_method: )
      @order = order
      @payment_method = payment_method
      super
    end

    def call
      @result = create_order_on_pay_tomorrow
      create_payment
      @result
    end

    private

    def create_order_on_pay_tomorrow
      SolidusPayTomorrow::Client::CreateOrderService.call(order: order, payment_method: payment_method)
    end

    def create_payment
      return unless order_successfully_created?

      ActiveRecord::Base.transaction do
        source = SolidusPayTomorrow::PaymentSource.create!(application_token: @result['token'],
          payment_method: payment_method)
        order.payments.create!(payment_method: payment_method, source: source, state: :checkout,
          response_code: @result['token'], amount: @order.total)
      end
    end

    def order_successfully_created?
      @result.key?('url') && @result.key?('token')
    end
  end
end
