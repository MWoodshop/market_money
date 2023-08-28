require 'rails_helper'

RSpec.describe Market, type: :model do
  it { should have_many(:market_vendors) }
  it { should have_many(:vendors).through(:market_vendors) }

  describe '#vendor_count' do
    it 'returns the number of vendors associated with a market' do
      market = create(:market)
      create(:market_vendor, market:)
      create(:market_vendor, market:)

      expect(market.vendor_count).to eq(2)
    end
  end
end
