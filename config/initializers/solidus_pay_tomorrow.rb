# frozen_string_literal: true

SolidusPayTomorrow.configure do |config|
  config.base_url = ENV['PAY_TOMORROW_REDIRECT_BASE_URL']
end
