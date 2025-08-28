# frozen_string_literal: true

require "spec_helper"

module Decidim
  # This spec makes sure that our customization to the record specific geocoding
  # will not get broken by the Geocoder gem's updates. The reason for the
  # customization is to pass the record in question for the geocoding searches
  # in order to correctly initialize the geocoding utility.
  describe Geocodable, configures_map: true do
    subject do
      record_class.new(
        organization:,
        address:
      )
    end

    let(:record_class) do
      Class.new(ApplicationRecord) do
        self.table_name = "decidim_dev_dummy_resources"

        attr_accessor :organization, :address, :latitude, :longitude

        geocoded_by :address
      end
    end
    let(:organization) { create(:organization) }
    let(:address) { "Carrer del Pare Llaurador, 113" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it "calls the Decidim geocoding utility and geocodes the resource" do
      subject.geocode
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)

      expect(subject).to be_geocoded
      expect(subject).to be_geocoded_and_valid

      # Check that the calculations are correctly passed to the
      # `Geocoder::Calculations` module.
      expect(
        subject.distance_to([60.169857, 24.938379], :km)
      ).to eq(2728.962159915394)
    end

    context "when the address is invalid" do
      let(:address) { "aaa" }
      let(:latitude) { Float::NAN }
      let(:longitude) { Float::NAN }

      it "calls the Decidim geocoding utility and try to geocode the resource, but the result is [NaN,NaN]" do
        subject.geocode
        expect(subject.latitude).to be_nan
        expect(subject.longitude).to be_nan

        expect(subject).to be_geocoded
        expect(subject).not_to be_geocoded_and_valid
      end
    end
  end
end
