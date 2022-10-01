# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Client::BaseService do
  let(:payment_method) { create(:pt_payment_method) }
  let(:token) do
    { access_token: "ad0cf6c6-6ef3-4185-8a25-ff575075fbc1",
      token_type: "bearer",
      refresh_token: "da8bf03e-4de4-4999-9f07-e446e39e9e88",
      expires_in: 38_488,
      scope: "openid" }
  end

  describe '#valid_token' do
    context "when current token is valid" do
      before do
        # Ensure that current token is set and valid
        described_class.current_token = token.merge({ expires_at: Time.zone.now + 10.hours })
        allow(HTTParty).to receive(:post)
      end

      it 'returns current token' do
        expect(described_class.new(payment_method: payment_method).valid_token).to eq(token[:access_token])
        expect(HTTParty).not_to have_received(:post).with(anything)
      end
    end

    context "when current token is invalid" do
      let(:token_url) { 'https://api-staging.paytomorrow.com/api/uaa/oauth/token' }
      let(:token_headers) do
        { 'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Basic #{payment_method.preferences[:signature]}" }
      end
      let(:token_body) do
        { grant_type: 'password',
          scope: 'openid',
          username: payment_method.preferences[:username],
          password: payment_method.preferences[:password] }
      end
      let(:http_response) { instance_double(HTTParty::Response, parsed_response: token.stringify_keys, success?: true) }

      before do
        allow(HTTParty).to receive(:post).with(token_url, headers: token_headers,
          body: URI.encode_www_form(token_body)).and_return(http_response)
      end

      it 'if not present, fetches new token and stores' do
        # Ensure that current token is not set
        described_class.current_token = nil
        expect(described_class.new(payment_method: payment_method).valid_token).to eq(token[:access_token])
        expect(HTTParty).to have_received(:post).with(token_url, headers: token_headers,
          body: URI.encode_www_form(token_body))
        expect(described_class.current_token).to match(hash_including(*token.keys, :expires_at))
      end

      it 'if expired, fetches new token and stores' do
        # Ensure that current token is set and expired
        described_class.current_token = token.merge({ expires_at: Time.zone.now - 10.hours })
        expect(described_class.new(payment_method: payment_method).valid_token).to eq(token[:access_token])
        expect(HTTParty).to have_received(:post).with(token_url, headers: token_headers,
          body: URI.encode_www_form(token_body))
        expect(described_class.current_token).to match(hash_including(*token.keys, :expires_at))
      end
    end
  end
end
