# frozen_string_literal: true

module SolidusPayTomorrow
  module Handlers
    class SuccessHandler
      attr_reader :order, :payment

      def initialize(order, payment)
        @order = order
        @payment = payment
      end

      def self.call(order, payment)
        new(order, payment).call
      end

      def call
        handle_success unless success_already_handled?
      end

      private

      def handle_success
        ActiveRecord::Base.transaction do
          update_payment
          update_order
        end
      end

      # If auto_capture is disabled, the payment is already processed and
      # it'll be captured from admin. Marking as pending is necessary to avoid
      # calling authorize! in this case
      def update_payment
        payment.update!(state: :pending) if should_update_payment?
      end

      def should_update_payment?
        !payment.payment_method.auto_capture?
      end

      def update_order
        order.next!
      end

      def success_already_handled?
        order.completed? || order.confirm?
      end
    end
  end
end
