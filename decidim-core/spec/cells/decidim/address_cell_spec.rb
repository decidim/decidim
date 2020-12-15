# frozen_string_literal: true

require "spec_helper"

describe Decidim::AddressCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/address", model) }
  let(:address) { "Carrer de Pepe Rubianes, 1" }
  let(:latitude) { 41.378481 }
  let(:longitude) { 2.1879618 }
  let(:model) { create(:dummy_resource, address: address, latitude: latitude, longitude: longitude) }

  let(:icondata_address) { subject.find(".card__icondata--address") }

  context "when rendering a model with address" do
    it "renders a resource address" do
      expect(icondata_address).to have_content(model.address)
      expect(icondata_address).to have_no_content(model.latitude)
      expect(icondata_address).to have_no_content(model.longitude)
    end
  end

  context "when rendering a model with location hints" do
    let(:location_hints) { "Lorem ipsum dolor sit amet consectetur" }

    before do
      allow(model).to receive(:location_hints).and_return location_hints
    end

    it "renders a resource location_hints" do
      expect(icondata_address).to have_content(model.address)
      expect(icondata_address).to have_content(model.location_hints)
      expect(icondata_address).to have_no_content(model.latitude)
      expect(icondata_address).to have_no_content(model.longitude)
    end
  end
end
