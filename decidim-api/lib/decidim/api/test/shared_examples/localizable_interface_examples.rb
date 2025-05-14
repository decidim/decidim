# frozen_string_literal: true

require "spec_helper"

shared_examples_for "localizable interface" do
  describe "address" do
    let(:query) { "{ address }" }

    it "returns the address of this proposal" do
      expect(response["address"]).to eq(model.address)
    end
  end

  describe "coordinates" do
    let(:query) { "{ coordinates { latitude longitude } }" }

    before do
      model.latitude = 2
      model.longitude = 40
      model.save!
    end
    it "returns the meeting's address" do
      expect(response["coordinates"]).to include(
        "latitude" => model.latitude,
        "longitude" => model.longitude
      )
    end
  end
end
