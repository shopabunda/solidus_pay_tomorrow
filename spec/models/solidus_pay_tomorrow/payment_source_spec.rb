require 'spec_helper'

RSpec.describe SolidusPayTomorrow::PaymentSource, type: :model do
  let(:payment_method) { create(:pt_payment_method) }
  let(:payment_source) { build(:pt_payment_source, payment_method: payment_method) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:payment_method_id) }
  end
end
