# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::HandleOrderCreationService do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:payment_method) { create(:pt_payment_method) }

  context 'when order is created successfully' do
    before do
      allow(SolidusPayTomorrow::Client::CreateOrderService).to receive(:call).with(order: order,
        payment_method: payment_method).and_return(
          { url: "https://api.paytomorrow.com/verify/personal?app=order-token&auth=auth-token",
            token: 'order-token' }.stringify_keys!
        )
    end

    it 'creates a payment in checkout state' do
      expect do
        described_class.call(order: order, payment_method: payment_method)
      end.to change { order.payments.count }.from(0).to(1)
      expect(order.payments.take).to have_attributes(state: 'checkout', response_code: 'order-token',
        amount: order.total)
    end
  end

  context 'when order creation fails' do
    before do
      allow(SolidusPayTomorrow::Client::CreateOrderService).to receive(:call).with(order: order,
        payment_method: payment_method).and_raise(
          StandardError, 'error message'
        )
    end

    it 'does not create a payment object' do
      expect(order.payments.count).to eq(0)
      expect do
        described_class.call(order: order, payment_method: payment_method)
      end.to raise_error(StandardError, 'error message')
      expect(order.payments.count).to eq(0)
    end
  end
end
