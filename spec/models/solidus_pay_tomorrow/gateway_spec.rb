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

    context 'when /settle call succeeds' do
      before do
        allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).with(
          order_token: payment.response_code,
          payment_method: payment_method
        ).and_return(capture_success_response)
      end

      it 'returns an active merchant billing success response' do
        result = described_class.new.capture(payment.amount.to_f,
          payment.response_code,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).to be_success
      end
    end

    context 'when /settle call fails' do
      before do
        allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).and_raise(StandardError)
      end

      it 'returns an active merchant billing failure response' do
        result = described_class.new.capture(payment.amount.to_f,
          payment.response_code,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).not_to be_success
      end
    end
  end

  describe '#void' do
    let(:void_success_response) do
      { status: 'ok',
        message: 'application cancelled',
        token: nil,
        maxApprovalAmount: nil,
        lender: nil }.stringify_keys!
    end

    context 'when /cancel call succeeds' do
      it 'returns an active merchant billing success response' do
        allow(SolidusPayTomorrow::Client::VoidService).to receive(:call).with(
          order_token: payment.response_code,
          payment_method: payment_method
        ).and_return(void_success_response)
        result = described_class.new.void(payment.response_code,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).to be_success
      end
    end

    context 'when /cancel call fails' do
      it 'returns an active merchant billing failure response' do
        allow(SolidusPayTomorrow::Client::VoidService).to receive(:call).and_raise(StandardError)
        result = described_class.new.void(payment.response_code,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).not_to be_success
      end
    end
  end

  describe '#credit' do
    let(:credit_success_response) do
      { status: 'ok',
        message: 'application refunded',
        token: nil,
        maxApprovalAmount: nil,
        lender: nil }.stringify_keys!
    end
    let(:refund_reason) { create(:refund_reason) }
    let(:refund) { create(:refund, reason: refund_reason) }

    context 'when /refund call succeeds' do
      before do
        allow(SolidusPayTomorrow::Client::CreditService).to receive(:call).with(
          order_token: payment.response_code,
          payment_method: payment_method,
          refund_reason: refund_reason.name
        ).and_return(credit_success_response)
      end

      it 'returns an active merchant billing success response' do
        result = described_class.new.credit(
          payment.amount.to_f,
          payment.response_code,
          originator: refund
        )
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).to be_success
      end
    end

    context 'when /refund call fails' do
      before do
        allow(SolidusPayTomorrow::Client::CreditService).to receive(:call).and_raise(StandardError)
      end

      it 'returns an active merchant billing failure response' do
        result = described_class.new.credit(payment.amount.to_f,
          payment.response_code,
          originator: refund)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).not_to be_success
      end
    end
  end

  describe '#authorize' do
    it 'raises NotImplementedError' do
      expect { described_class.new.authorize }.to raise_error(NotImplementedError)
    end
  end

  describe '#purchase' do
    let(:capture_success_response) do
      { status: 'ok',
        message: 'application settled',
        token: nil,
        maxApprovalAmount: nil,
        lender: nil }.stringify_keys!
    end

    context 'when /settle call succeeds' do
      before do
        allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).with(
          order_token: payment.response_code,
          payment_method: payment_method
        ).and_return(capture_success_response)
      end

      it 'returns an active merchant billing success response' do
        result = described_class.new.purchase(payment.amount.to_f,
          payment_source,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).to be_success
      end
    end

    context 'when /settle call fails' do
      before do
        allow(SolidusPayTomorrow::Client::CaptureService).to receive(:call).and_raise(StandardError)
      end

      it 'returns an active merchant billing failure response' do
        result = described_class.new.purchase(payment.amount.to_f,
          payment_source,
          originator: payment)
        expect(result).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(result).not_to be_success
      end
    end
  end
end
