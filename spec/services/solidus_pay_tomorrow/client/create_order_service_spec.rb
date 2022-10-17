# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Client::CreateOrderService do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:payment_method) { create(:pt_payment_method) }
  let(:success_response) do
    { url: "https://subdomain.paytomorrow.com/verify/personal?app=11171280-8e2a-4b2e-8855-76285fc578c6&auth=e3de6c12-ed9a-4bb1-a066-5c62a1ba19d4",
      token: "11171280-8e2a-4b2e-8855-76285fc578c6" }.stringify_keys!
  end
  let(:http_response) { instance_double(HTTParty::Response, parsed_response: success_response, success?: true) }
  let(:full_name) { Spree::Address::Name.new(order.bill_address.name) }

  before do
    url = 'https://api-staging.paytomorrow.com/api/application/ecommerce/orders'
    headers = { 'Authorization': "Bearer access-token",
                'Content-Type': 'application/json' }
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SolidusPayTomorrow::Client::BaseService).to receive(:valid_token).and_return('access-token')
    # rubocop:enable RSpec/AnyInstance
    allow(HTTParty).to receive(:post).with(url, headers: headers, body: expected_body).and_return(http_response)
  end

  describe '#call' do
    it 'creates successful order' do
      response = described_class.call(order: order, payment_method: payment_method)
      expect(response).to match(hash_including('url', 'token'))
    end

    def expected_body
      line_item1 = order.line_items.first
      line_item2 = order.line_items.last
      { orderId: order.number,
        firstName: full_name.first_name,
        lastName: full_name.last_name,
        street: order.bill_address.address1,
        city: order.bill_address.city,
        zip: order.bill_address.zipcode,
        state: order.bill_address.state.abbr,
        email: order.email,
        returnUrl: 'https://domain.com/webhooks/return',
        cancelUrl: 'https://domain.com/webhooks/cancel',
        notifyUrl: 'https://domain.com/webhooks/notify',
        cellPhone: order.bill_address.phone,
        loanAmount: order.total.to_i,
        applicationItems:
          [{ description: line_item1.description, quantity: line_item1.quantity,
             price: line_item1.price.to_f, sku: line_item1.variant.sku },
           { description: line_item2.description, quantity: line_item2.quantity,
             price: line_item2.price.to_f, sku: line_item2.variant.sku }] }.to_json
    end
  end
end
