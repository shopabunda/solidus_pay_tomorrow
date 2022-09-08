# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Client::CaptureService do
  let(:payment_method) { create(:pt_payment_method) }
  let(:headers) {
    { 'Authorization': "Bearer access-token",
      'Content-Type': 'application/json' }
  }
  let(:url) { "https://api-staging.paytomorrow.com/api/ecommerce/application/order_token/settle" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SolidusPayTomorrow::Client::BaseService).to receive(:valid_token).and_return('access-token')
    # rubocop:enable RSpec/AnyInstance
  end

  describe '#call' do
    context 'when successful settlement' do
      let(:success_response) do
        { status: 'ok',
          message: 'application settled',
          token: nil,
          maxApprovalAmount: nil,
          lender: nil }.stringify_keys!
      end
      let(:http_response) { instance_double(HTTParty::Response, parsed_response: success_response, success?: true) }

      before do
        allow(HTTParty).to receive(:post).with(url, headers: headers).and_return(http_response)
      end

      it 'checks response' do
        response = described_class.call(order_token: 'order_token', payment_method: payment_method)

        expect(response).to include('status' => 'ok', 'message' => 'application settled')
      end
    end

    context 'when failed settlement' do
      let(:failed_response) do
        { timestamp: '2022-09-12T09:18:00.219+00:00',
          status: 400,
          error: 'Bad Request',
          message: "",
          path: '/ecommerce/application/order_token/settle' }.stringify_keys!
      end
      let(:http_response) { instance_double(HTTParty::Response, parsed_response: failed_response, success?: false) }

      before do
        allow(HTTParty).to receive(:post).with(url, headers: headers).and_return(http_response)
      end

      it 'raises StandardError' do
        expect do
          described_class.call(order_token: 'order_token', payment_method: payment_method)
        end.to raise_error(StandardError, 'Bad Request: ')
      end
    end
  end
end
