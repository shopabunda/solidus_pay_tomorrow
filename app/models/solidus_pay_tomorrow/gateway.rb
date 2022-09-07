# frozen_string_literal: true

module SolidusPayTomorrow
  class Gateway
    def initialize(options = {}); end

    def authorize
      not_implemented(__method__)
    end

    def purchase
      not_implemented(__method__)
    end

    def capture
      not_implemented(__method__)
    end

    def void
      not_implemented(__method__)
    end

    def credit
      not_implemented(__method__)
    end

    private

    # Remove this once all methods are implemented
    def not_implemented(method_name)
      raise NotImplementedError, "#{method_name} method has not been implemented in #{self.class} class"
    end
  end
end
