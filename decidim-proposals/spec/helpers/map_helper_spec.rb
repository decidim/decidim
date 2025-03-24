# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe MapHelper do
      include Decidim::LayoutHelper
      include ::Devise::Test::ControllerHelpers

      let!(:organization) { create(:organization) }
      let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, organization:) }
      let!(:user) { create(:user, organization:) }
      let!(:proposals) { create_list(:proposal, 5, address:, latitude:, longitude:, component: proposal_component) }
      let!(:proposal) { proposals.first }
      let(:address) { "Carrer Pic de Peguera 15, 17003 Girona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      describe "#has_position?" do
        subject { helper.has_position?(proposal) }

        it { is_expected.to be_truthy }

        context "when proposal is not geocoded" do
          let!(:proposals) { create_list(:proposal, 5, address:, latitude: nil, longitude: nil, component: proposal_component) }

          it { is_expected.to be_falsey }
        end
      end

      describe "#proposal_preview_data_for_map" do
        subject { helper.proposal_preview_data_for_map(proposal) }

        let(:marker) { subject[:marker] }

        it "returns preview data" do
          expect(subject[:type]).to eq("drag-marker")
          expect(marker["latitude"]).to eq(latitude)
          expect(marker["longitude"]).to eq(longitude)
        end
      end
    end
  end
end
