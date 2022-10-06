# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Api::CreateOrderController, type: :request do
  describe '#create' do
    subject(:call) do
      post "/api/orders/#{order.number}/pay_tomorrow", params: params, headers: headers
    end

    let(:payment_method) { create(:pt_payment_method) }
    let(:user) { create(:user, email: 'user@bolt.com') }
    let(:params) { { payment_method: payment_method.id } }
    let(:headers) { { 'X-Spree-Order-Token' => order.guest_token } }
    let(:order) { create(:order) }

    context 'when order is created successfully' do
      before do
        allow(SolidusPayTomorrow::Client::CreateOrderService).to receive(:call).with(order: order,
          payment_method: payment_method).and_return(
            { url: "https://api.paytomorrow.com/verify/personal?app=order-token&auth=auth-token",
              token: 'order-token' }.stringify_keys
          )
      end

      it 'returns created status code' do
        call
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include({ url: "https://api.paytomorrow.com/verify/personal?app=order-token&auth=auth-token",
                                                  token: 'order-token' }.stringify_keys!)
      end
    end

    context 'when order creation fails' do
      before do
        allow(SolidusPayTomorrow::Client::CreateOrderService).to receive(:call).with(order: order,
          payment_method: payment_method).and_raise(
            StandardError, 'error message'
          )
      end

      it 'returns created status code' do
        call
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to include({ message: 'error message' }.stringify_keys!)
      end
    end
  end
end
