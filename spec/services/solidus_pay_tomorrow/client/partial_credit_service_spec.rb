# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Client::PartialCreditService do
  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { create(:pt_payment_source, payment_method: payment_method) }
  let(:payment) {
    create(:payment, order: order, payment_method: payment_method, source: payment_source,
      state: :completed, response_code: payment_source.application_token,
      amount: order.total)
  }
  let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:complete) }
  let(:refund_reason) { create(:refund_reason) }
  let(:refund) { create(:refund, payment: payment, amount: payment.amount - 1, reason: refund_reason) }

  let(:headers) {
    { 'Authorization': "Bearer access-token",
      'Content-Type': 'application/json' }
  }
  let(:url) { "https://api-staging.paytomorrow.com/api/ecommerce/application/order-token/partial/refund" }
  let(:http_response) { instance_double(HTTParty::Response, parsed_response: success_response, success?: true) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SolidusPayTomorrow::Client::BaseService).to receive(:valid_token).and_return('access-token')
    # rubocop:enable RSpec/AnyInstance
  end

  describe '#call' do
    context 'when successful partial refund' do
      let(:success_response) do
        { status: 'ok',
          message: 'Partial refund processed',
          token: nil,
          maxApprovalAmount: nil,
          lender: nil }.stringify_keys!
      end
      let(:http_response) { instance_double(HTTParty::Response, parsed_response: success_response, success?: true) }

      before do
        allow(HTTParty).to receive(:post).with(url, headers: headers, body: refund_body).and_return(http_response)
      end

      it 'checks response' do
        response = described_class.call(refund: refund,
          payment_method: payment_method)

        expect(response).to include('status' => 'ok', 'message' => 'Partial refund processed')
      end
    end

    context 'when refund fails' do
      let(:failed_response) do
        { timestamp: '2022-09-12T09:18:00.219+00:00',
          status: 500,
          error: 'Internal Server Error',
          message: "",
          path: '/ecommerce/application/order_token/partial/refund' }.stringify_keys!
      end
      let(:http_response) { instance_double(HTTParty::Response, parsed_response: failed_response, success?: false) }

      before do
        allow(HTTParty).to receive(:post).with(url, headers: headers, body: refund_body).and_return(http_response)
      end

      it 'raises StandardError' do
        expect do
          described_class.call(refund: refund,
            payment_method: payment_method)
        end.to raise_error(StandardError, 'Internal Server Error: ')
      end
    end

    def refund_body
      line_item = order.line_items.first
      { loanAmount: payment.amount - refund.amount,
        items: [{
          description: line_item.description,
          quantity: line_item.quantity,
          price: line_item.price.to_f
        }] }.to_json
    end
  end
end
