# frozen_string_literal: true

module SolidusPayTomorrow
  module Api
    class BaseController < ::Spree::Api::BaseController
      rescue_from StandardError, with: :handle_error

      def handle_error(error)
        render json: { message: error.message }, status: :unprocessable_entity
      end
    end
  end
end
