require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Gateway, type: :model do
  describe '#authorize' do
    it 'raises NotImplementedError' do
      expect { described_class.new.authorize }.to raise_error(NotImplementedError)
    end
  end

  describe '#capture' do
    it 'raises NotImplementedError' do
      expect { described_class.new.capture }.to raise_error(NotImplementedError)
    end
  end

  describe '#void' do
    it 'raises NotImplementedError' do
      expect { described_class.new.void }.to raise_error(NotImplementedError)
    end
  end

  describe '#credit' do
    it 'raises NotImplementedError' do
      expect { described_class.new.credit }.to raise_error(NotImplementedError)
    end
  end

  describe '#purchase' do
    it 'raises NotImplementedError' do
      expect { described_class.new.purchase }.to raise_error(NotImplementedError)
    end
  end
end
