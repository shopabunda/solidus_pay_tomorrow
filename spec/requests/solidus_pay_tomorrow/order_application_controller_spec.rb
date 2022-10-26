# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::OrderApplicationController, type: :request do
  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }
  let(:payment) {
    create(:payment, order: order, payment_method: payment_method, source: payment_source,
      state: :checkout, response_code: payment_source.application_token,
      amount: order.total)
  }
  let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:current_order).and_return(order)
    # rubocop:enable RSpec/AnyInstance
  end

  describe 'GET /pay_tomorrow/return' do
    context 'when PayTomorrow redirects on return URL - success ' do
      it 'set correct order and payment status and redirect' do
        # Ensure that the order is in 'payment' state and payment is in 'checkout' state
        # before the request
        expect(order.state).to eq('payment')
        expect(payment.reload.state).to eq('checkout')
        expect(get(spree.pay_tomorrow_return_path)).to redirect_to('/checkout/confirm')

        expect(order.state).to eq('confirm')
        expect(payment.reload.state).to eq('checkout')
      end
    end
  end

  describe 'GET /pay_tomorrow/cancel' do
    context 'when PayTomorrow redirects on cancel URL' do
      it 'set correct order and payment status and redirect' do
        expect(order.state).to eq('payment')
        expect(payment.reload.state).to eq('checkout')
        expect(get(spree.pay_tomorrow_cancel_path)).to redirect_to('/checkout/payment')

        expect(order.state).to eq('payment')
        expect(payment.reload.state).to eq('invalid')
      end
    end
  end
end
