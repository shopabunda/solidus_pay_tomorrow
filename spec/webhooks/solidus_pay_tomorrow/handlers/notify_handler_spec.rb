# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Handlers::NotifyHandler do
  subject(:handler) { described_class.new({}) }

  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }

  it { expect(described_class).to respond_to(:call).with(1).arguments }

  it { expect(handler).to respond_to(:call).with(0).arguments }

  context 'when notify is for pending callback' do
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
        pt_amount: 100,
        uuid: payment.response_code }
    }

    it 'calls the SuccessHandler with correct params' do
      allow(SolidusPayTomorrow::Handlers::SuccessHandler).to receive(:call).with(order, payment)
      described_class.call(pending_params)
      expect(SolidusPayTomorrow::Handlers::SuccessHandler).to have_received(:call).with(order, payment)
    end
  end
end
