require 'rails_helper'

RSpec.describe MarketVendor, type: :model do
  it { should belong_to(:market) }
  it { should belong_to(:vendor) }

  describe 'validations' do
    subject { create(:market_vendor) }
    it {
      should validate_uniqueness_of(:market_id).scoped_to(:vendor_id).with_message('association between market and vendor already exists')
    }
    it { should validate_presence_of(:market_id) }
  end
end
