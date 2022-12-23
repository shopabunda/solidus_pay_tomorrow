# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Api::WebhooksController, type: :request do
  subject(:notify_pending_call) do
    post "/pay_tomorrow/notify", params: pending_params
  end

  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }

  describe 'POST /pay_tomorrow/notify' do
    context 'when uuid verification fails' do
      let(:pending_params) {
        { txn_type: 'cart',
          payment_status: 'pending',
          pt_currency: 'USD',
          pt_amount: 100,
          uuid: 'an invalid uuid' }
      }

      it 'gracefully returns with error message' do
        notify_pending_call
        expect(response.status).to be(200)
        expect(JSON(response.body)['message']).to \
          eq("Couldn't find payment with uuid: an invalid uuid")
      end
    end

    context 'when user does not click on Close button on PayTomorrow page' do
      # In this case, the application is completed, but since user hasn't been
      # redirected to pay_tomorrow_return endpoint, the order isn't updated
      # This should be done by the Notify webhook
      let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery) }
      let(:payment) {
        create(:payment, order: order, payment_method: payment_method, source: payment_source,
          state: :checkout, response_code: payment_source.application_token,
          amount: order.total)
      }
      let(:pending_params) {
        { txn_type: 'cart',
          payment_status: 'pending',
          pt_currency: 'USD',
          pt_amount: order.amount,
          uuid: payment.response_code }
      }

      it 'updates the order accordingly' do
        # Ensure that the order is in 'payment' state and payment is in 'checkout' state
        # before the request
        expect(order.state).to eq('payment')
        expect(payment.reload.state).to eq('checkout')
        notify_pending_call
        expect(order.reload.state).to eq('confirm')
      end
    end

    context 'when user clicks on Close button on PayTomorrow page' do
      # In this case, the application is completed, and user clicked the close
      # button and got redirected to pay_tomorrow_return endpoint,
      # the order is already handled.
      # Notify webhook should do nothing in this case
      let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }
      let(:payment) {
        create(:payment, order: order, payment_method: payment_method, source: payment_source,
          state: :checkout, response_code: payment_source.application_token,
          amount: order.total)
      }
      let(:pending_params) {
        { txn_type: 'cart',
          payment_status: 'pending',
          pt_currency: 'USD',
          pt_amount: order.amount,
          uuid: payment.response_code }
      }

      it 'does nothing, order already updated' do
        # Ensure that the order is in 'confirm' state and payment is in 'checkout' state
        # before the request
        expect(order.state).to eq('confirm')
        expect(payment.reload.state).to eq('checkout')
        notify_pending_call
        expect(order.reload.state).to eq('confirm')
      end
    end
  end
end
