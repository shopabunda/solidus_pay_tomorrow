# frozen_string_literal: true

module SolidusPayTomorrow
  class OrderApplicationController < Spree::StoreController
    def success
      # If auto_capture is disabled, the payment is already processed and
      # it'll be captured from admin. Marking as pending is necessary to avoid
      # calling authorize! in this case
      payment.update!(state: :pending) unless payment.payment_method.auto_capture?
      current_order.next!

      flash[:notice] = 'Payment Successful!'
      redirect_to checkout_state_path('confirm')
    end

    def cancel
      payment.update!(state: :invalid)

      flash[:error] = "Payment failed!"
      redirect_to checkout_state_path('payment')
    end

    private

    # There's only one payment in checkout state for a given source type
    def payment
      current_order.payments.where(state: :checkout,
        source_type: 'SolidusPayTomorrow::PaymentSource').take
    end
  end
end
