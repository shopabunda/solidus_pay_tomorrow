# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Handlers::SuccessHandler do
  subject(:handler) { described_class.new(double, double) }

  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }

  it { expect(described_class).to respond_to(:call).with(2).arguments }

  it { expect(handler).to respond_to(:call).with(0).arguments }

  context 'when order is still in payment state' do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery) }
    let(:payment) {
      create(:payment, order: order, payment_method: payment_method, source: payment_source,
        state: :checkout, response_code: payment_source.application_token,
        amount: order.total)
    }

    it 'update the order' do
      expect(order.state).to eq('payment')
      described_class.call(order, payment)
      expect(order.reload.state).to eq('confirm')
    end
  end

  context 'when order is already confirmed' do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }
    let(:payment) {
      create(:payment, order: order, payment_method: payment_method, source: payment_source,
        state: :checkout, response_code: payment_source.application_token,
        amount: order.total)
    }

    it "doesn't do anything" do
      expect(order.state).to eq('confirm')
      described_class.call(order, payment)
      expect(order.reload.state).to eq('confirm')
    end
  end
end
