# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Consultations
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "consultations" do
        let!(:consultation1) { create(:consultation, organization: current_organization) }
        let!(:consultation2) { create(:consultation, organization: current_organization) }
        let!(:consultation3) { create(:consultation) }

        let(:query) { %({ consultations { id }}) }

        it "returns all the consultations" do
          expect(response["consultations"]).to include("id" => consultation1.id.to_s)
          expect(response["consultations"]).to include("id" => consultation2.id.to_s)
          expect(response["consultations"]).not_to include("id" => consultation3.id.to_s)
        end
      end

      describe "consultation" do
        let(:query) { %({ consultation(id: \"#{id}\") { id }}) }

        context "with a consultation that belongs to the current organization" do
          let!(:consultation) { create(:consultation, organization: current_organization) }
          let(:id) { consultation.id }

          it "returns the consultation" do
            expect(response["consultation"]).to eq("id" => consultation.id.to_s)
          end
        end

        context "with a conference of another organization" do
          let!(:consultation) { create(:consultation) }
          let(:id) { consultation.id }

          it "returns nil" do
            expect(response["consultation"]).to be_nil
          end
        end
      end
    end
  end
end
