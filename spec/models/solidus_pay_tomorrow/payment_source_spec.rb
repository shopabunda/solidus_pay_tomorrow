require 'spec_helper'

RSpec.describe SolidusPayTomorrow::PaymentSource, type: :model do
  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { build(:pt_payment_source, payment_method: payment_method) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:payment_method_id) }
  end

  describe "#can_void?" do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:complete) }
    let(:payment) {
      build_stubbed(:payment, order: order, payment_method: payment_method, source: payment_source,
        state: :completed, response_code: payment_source.application_token,
        amount: order.total)
    }

    context 'when payment is in state - completed' do
      it 'returns false' do
        expect(payment_source).not_to be_can_void(payment)
      end
    end

    context 'when payment is in state - invalid' do
      it 'returns false' do
        payment.state = 'invalid'
        expect(payment_source).not_to be_can_void(payment)
      end
    end

    context 'when payment is in state - void' do
      it 'returns false' do
        payment.state = 'void'
        expect(payment_source).not_to be_can_void(payment)
      end
    end

    context 'when payment is in state - pending' do
      it 'returns true' do
        payment.state = 'pending'
        expect(payment_source).to be_can_void(payment)
      end
    end
  end
end
