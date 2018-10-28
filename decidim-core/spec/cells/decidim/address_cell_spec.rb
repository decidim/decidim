# frozen_string_literal: true

require "spec_helper"

describe Decidim::AddressCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/address", model) }
  let(:address) { "Carrer del Pare Llaurador, 113" }
  let(:latitude) { nil }
  let(:longitude) { nil }
  let(:location_hints) { nil }
  let(:model) { create(:dummy_resource, address: address, latitude: latitude, longitude: longitude, location_hints: location_hints) }

  context "when rendering a model with address" do
    it "renders a resource address" do
      within ".card__icondata--address" do
        expect(subject).to have_content(model.address)
        expect(subject).to have_no_content(model.latitude)
        expect(subject).to have_no_content(model.langitude)
      end
    end
  end

  context "when rendering a model with latitude and longitude" do
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }

    it "renders a resource latitude and longitude" do
      within ".card__icondata--address" do
        expect(subject).to have_content(model.address)
        expect(subject).to have_content(model.latitude)
        expect(subject).to have_content(model.longitude)
      end
    end
  end

  context "when rendering a model with location hints" do
    let(:location_hints) { "Lorem ipsum dolor sit amet consectetur" }

    it "renders a resource location_hints" do
      within ".card__icondata--address" do
        expect(subject).to have_content(model.address)
        expect(subject).to have_content(model.location_hints)
      end
    end
  end
end
