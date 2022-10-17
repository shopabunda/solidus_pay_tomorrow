# frozen_string_literal: true

module SolidusPayTomorrow
  class BaseService
    def initialize(**_args) end

    class << self
      def call(*args, **kwargs, &block)
        new(*args, **kwargs, &block).call
      end
    end
  end
end
