# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class CreateOrderService < SolidusPayTomorrow::Client::BaseService
      attr_reader :order

      CREATE_ENDPOINT = 'api/application/ecommerce/orders'

      # @param order [Spree::Order] Spree order
      # @param payment_method [SolidusPayTomorrow::PaymentMethod]
      def initialize(order:, payment_method:)
        @order = order
        super
      end

      def call
        create
      end

      private

      def create
        handle_errors!(HTTParty.post(uri, headers: auth_headers, body: create_body.to_json))
      end

      def uri
        "#{api_base_url}/#{CREATE_ENDPOINT}"
      end

      # TODO: Update URI once implemented
      def webhook_url(type)
        "https://domain.com/webhooks/#{type}"
      end

      def create_body
        { orderId: order.number,
          firstName: full_name.first_name,
          lastName: full_name.last_name,
          street: order.bill_address.address1,
          city: order.bill_address.city,
          zip: order.bill_address.zipcode,
          state: order.bill_address.state.abbr,
          email: order.email,
          returnUrl: webhook_url('return'),
          cancelUrl: webhook_url('cancel'),
          notifyUrl: webhook_url('notify'),
          cellPhone: order.bill_address.phone,
          loanAmount: order.total.to_i,
          applicationItems: items }
      end

      def full_name
        Spree::Address::Name.new(order.bill_address.name)
      end

      # Ref: https://docs.paytomorrow.com/docs/api-reference/api/create-order/
      # for API ref
      def items
        order.line_items.map do |line_item|
          { description: line_item.product.description,
            quantity: line_item.quantity,
            price: line_item.price.to_f,
            sku: line_item.variant.sku }
        end
      end
    end
  end
end
