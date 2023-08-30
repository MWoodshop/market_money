require 'rails_helper'

RSpec.describe Vendor, type: :model do
  it { should have_many(:market_vendors) }
  it { should have_many(:markets).through(:market_vendors) }

  context 'validations' do
    it 'is valid with valid attributes' do
      vendor = build(:vendor, name: 'Test Vendor', description: 'Test Description', contact_name: 'Test Contact',
                              contact_phone: '123-456-7890', credit_accepted: true)
      expect(vendor).to be_valid
    end

    it 'is not valid without a name' do
      vendor = build(:vendor, name: nil)
      expect(vendor).to_not be_valid
    end

    it 'is not valid without a description' do
      vendor = build(:vendor, description: nil)
      expect(vendor).to_not be_valid
    end

    it 'is not valid without a contact name' do
      vendor = build(:vendor, contact_name: nil)
      expect(vendor).to_not be_valid
    end

    it 'is not valid without a contact phone' do
      vendor = build(:vendor, contact_phone: nil)
      expect(vendor).to_not be_valid
    end

    it 'is not valid without a credit accepted' do
      vendor = build(:vendor, credit_accepted: nil)
      expect(vendor).to_not be_valid
    end

    it 'is valid when credit accepted is true' do
      vendor = build(:vendor, credit_accepted: true)
      expect(vendor).to be_valid
    end

    it 'is valid when credit accepted is false' do
      vendor = build(:vendor, credit_accepted: false)
      expect(vendor).to be_valid
    end
  end
end
