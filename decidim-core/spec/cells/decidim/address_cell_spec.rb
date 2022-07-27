# frozen_string_literal: true

require "spec_helper"

describe Decidim::AddressCell, type: :cell do
  controller Decidim::ApplicationController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/address", model) }
  let(:address_text) { "Foo bar Street, 1" }
  let(:js_alert) { "<script>alert(1)</script>" }
  let(:address) { "#{address_text}#{js_alert}" }
  let(:latitude) { 41.378481 }
  let(:longitude) { 2.1879618 }
  let(:model) { create(:dummy_resource, address:, latitude:, longitude:) }
  let(:hint_text) { "Lorem ipsum dolor sit amet consectetur" }
  let(:location_hints) { "#{hint_text}#{js_alert}" }
  let(:location_text) { "This is my location" }
  let(:location) { "#{location_text}#{js_alert}" }

  let(:icondata_address) { subject.find(".card__icondata--address") }

  before do
    allow(model).to receive(:location_hints).and_return location_hints
    allow(model).to receive(:location).and_return location
  end

  it "renders a resource address and related fields" do
    expect(icondata_address).to have_content(address_text)
    expect(icondata_address).to have_content(hint_text)
    expect(icondata_address).to have_content(location_text)
    expect(icondata_address.to_s).not_to match("<script>")
    expect(icondata_address).to have_no_content(model.latitude)
    expect(icondata_address).to have_no_content(model.longitude)
  end
end
