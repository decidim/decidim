# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Initiatives
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "initiativesTypes" do
        let!(:initiatives_type1) { create(:initiatives_type, organization: current_organization) }
        let!(:initiatives_type2) { create(:initiatives_type, organization: current_organization) }
        let!(:initiatives_type3) { create(:initiatives_type) }

        let(:query) { %({ initiativesTypes { id }}) }

        it "returns all the groups" do
          expect(response["initiativesTypes"]).to include("id" => initiatives_type1.id.to_s)
          expect(response["initiativesTypes"]).to include("id" => initiatives_type2.id.to_s)
          expect(response["initiativesTypes"]).not_to include("id" => initiatives_type3.id.to_s)
        end
      end

      describe "initiativesType" do
        let(:model) { create(:initiatives_type, organization: current_organization) }
        let(:query) { %({ initiativesType(id: \"#{model.id}\") { id }}) }

        it "returns the initiativesType" do
          expect(response["initiativesType"]).to eq("id" => model.id.to_s)
        end
      end

      describe "initiatives" do
        let!(:initiative1) { create(:initiative, organization: current_organization) }
        let!(:initiative2) { create(:initiative, organization: current_organization) }
        let!(:initiative3) { create(:initiative) }

        let(:query) { %({ initiatives { id }}) }

        it "returns all the consultations" do
          expect(response["initiatives"]).to include("id" => initiative1.id.to_s)
          expect(response["initiatives"]).to include("id" => initiative2.id.to_s)
          expect(response["initiatives"]).not_to include("id" => initiative3.id.to_s)
        end
      end

      describe "initiative" do
        let(:query) { %({ initiative(id: \"#{id}\") { id }}) }

        context "with a consultation that belongs to the current organization" do
          let!(:initiative) { create(:initiative, organization: current_organization) }
          let(:id) { initiative.id }

          it "returns the initiative" do
            expect(response["initiative"]).to eq("id" => initiative.id.to_s)
          end
        end

        context "with a conference of another organization" do
          let!(:initiative) { create(:initiative) }
          let(:id) { initiative.id }

          it "returns nil" do
            expect(response["initiative"]).to be_nil
          end
        end
      end
    end
  end
end
