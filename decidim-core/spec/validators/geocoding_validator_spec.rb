# frozen_string_literal: true

require "spec_helper"

describe GeocodingValidator do
  subject { validatable.new(address: address, component: component) }

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :address
      attribute :latitude
      attribute :longitude
      attribute :component

      validates :address, geocoding: true
    end
  end

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:component) { create(:component) }

  context "when the address is valid" do
    before do
      stub_geocoding(address, [latitude, longitude])
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
      stub_geocoding(address, [])
    end

    it { is_expected.to be_invalid }
  end
end
