# frozen_string_literal: true

require "spec_helper"

describe "User location button" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           participatory_space: participatory_process,
           settings: { geocoding_enabled: })
  end
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }
  let(:manifest) { [:proposals] }

  before do
    stub_geocoding(address, [latitude, longitude])
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "uses device location" do
    context "when geocoding_enabled" do
      let(:geocoding_enabled) { true }

      it "has my location button" do
        expect(page).to have_button("Use my current location")
      end

      context "when option disabled" do
        let(:geocoding_enabled) { false }

        it "does not has the location button" do
          expect(page).to have_no_button("Use my current location")
        end
      end
    end
  end

  describe "when public" do
    before do
      visit_component
      click_link_or_button "New proposal"
    end

    it_behaves_like "uses device location"
  end

  context "when admin" do
    before do
      visit manage_component_path(component)
      click_link_or_button "New proposal"
    end

    it_behaves_like "uses device location"
  end
end
