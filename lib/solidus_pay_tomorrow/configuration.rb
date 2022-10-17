# frozen_string_literal: true

module SolidusPayTomorrow
  class Configuration
    attr_accessor :base_url
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
