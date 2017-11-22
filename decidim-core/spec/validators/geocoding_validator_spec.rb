# frozen_string_literal: true

require "spec_helper"

describe GeocodingValidator do
  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :address
      attribute :latitude
      attribute :longitude

      validates :address, geocoding: true

      def feature
        FactoryBot.create(:feature)
      end
    end
  end

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:subject) { validatable.new(address: address) }

  context "when the address is valid" do
    before do
      Geocoder::Lookup::Test.add_stub(
        address,
        [{ "latitude" => latitude, "longitude" => longitude }]
      )
    end

    it "uses Geocoder to compute its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end
  end

  context "when the address is not valid" do
    let(:address) { "The post-apocalyptic Land of Ooo" }

    before do
      Geocoder::Lookup::Test.add_stub(address, [])
    end

    it { is_expected.to be_invalid }
  end
end
