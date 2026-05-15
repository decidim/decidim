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

  let(:icondata_address) { subject.find(".address") }

  context "with a location" do
    before do
      allow(model).to receive(:location_hints).and_return location_hints
      allow(model).to receive(:location).and_return location
    end

    it "renders a resource address and related fields" do
      expect(icondata_address).to have_content(address_text)
      expect(icondata_address).to have_content(hint_text)
      expect(icondata_address).to have_content(location_text)
      expect(icondata_address.to_s).not_to match(/<script>/i)
      expect(icondata_address).to have_no_content(model.latitude)
      expect(icondata_address).to have_no_content(model.longitude)
    end
  end

  context "when address is pending" do
    let(:location) { { "ca" => "", "en" => "", "es" => "", "machine_translations" => { "es" => "Location" } } }

    before do
      allow(model).to receive(:location).and_return location
      allow(model).to receive(:pending_location?).and_return(true)
    end

    it "renders pending address text" do
      expect(subject.find(".address__location")).to have_content(I18n.t("show.pending_address", scope: "decidim.meetings.meetings"))
    end
  end

  context "with an online meeting url" do
    let(:my_cell) { cell("decidim/address", model, online: true) }
    let(:model) { create(:dummy_resource) }
    let(:online_meeting_url) { "https://decidim.org" }

    before do
      allow(model).to receive(:online?).and_return true
      allow(model).to receive(:type_of_meeting).and_return :online
      allow(model).to receive(:iframe_access_level_allowed_for_user?).and_return true
      allow(model).to receive(:online_meeting_url).and_return online_meeting_url
    end

    it "renders the URL" do
      expect(subject).to have_content "https://decidim.org"
    end

    context "with a malformed URL" do
      let(:online_meeting_url) { "https://decidim.org/?v=h<script>alert(1)</script>" }

      it "renders the escaped URL" do
        expect(subject).to have_content "https://decidim.org/?v=h%3Cscript%3Ealert(1)%3C/script%3E"
      end
    end
  end
end
