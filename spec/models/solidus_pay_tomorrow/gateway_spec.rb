require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Gateway, type: :model do
  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }
  let(:payment) {
    create(:payment, order: order, payment_method: payment_method, source: payment_source,
      state: :checkout, response_code: payment_source.application_token,
      amount: order.total)
  }
  let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:complete) }

  describe '#capture' do
    let(:capture_success_response) do
      { status: 'ok',
        message: 'application settled',
        token: nil,
        maxApprovalAmount: nil,
        lender: nil }.stringify_keys!
    end

    it 'returns an active merchant billing success response' do
      allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).with(
        order_token: payment.response_code,
        payment_method: payment_method
      ).and_return(capture_success_response)
      result = described_class.new.capture(payment.amount.to_f,
        payment.response_code,
        originator: payment)
      expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
      expect(result).to be_success
    end

    it 'returns an active merchant billing failure response' do
      allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).and_raise(StandardError)
      result = described_class.new.capture(payment.amount.to_f,
        payment.response_code,
        originator: payment)
      expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
      expect(result).not_to be_success
    end
  end

  describe '#authorize' do
    it 'raises NotImplementedError' do
      expect { described_class.new.authorize }.to raise_error(NotImplementedError)
    end
  end

  describe '#void' do
    it 'raises NotImplementedError' do
      expect { described_class.new.void }.to raise_error(NotImplementedError)
    end
  end

  describe '#credit' do
    it 'raises NotImplementedError' do
      expect { described_class.new.credit }.to raise_error(NotImplementedError)
    end
  end

  describe '#purchase' do
    it 'raises NotImplementedError' do
      expect { described_class.new.purchase }.to raise_error(NotImplementedError)
    end
  end
end
