# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Initiatives
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

      describe "initiativesTypes" do
        let!(:initiatives_type_1) { create(:initiatives_type, organization: current_organization) }
        let!(:initiatives_type_2) { create(:initiatives_type, organization: current_organization) }
        let!(:initiatives_type_3) { create(:initiatives_type) }

        let(:query) { %({ initiativesTypes { id }}) }

        it "returns all the groups" do
          expect(response["initiativesTypes"]).to include("id" => initiatives_type_1.id.to_s)
          expect(response["initiativesTypes"]).to include("id" => initiatives_type_2.id.to_s)
          expect(response["initiativesTypes"]).not_to include("id" => initiatives_type_3.id.to_s)
        end
      end

      describe "initiativesType" do
        let(:model) { create(:initiatives_type, organization: current_organization) }
        let(:query) { %({ initiativesType(id: \"#{model.id}\") { id }}) }

        it "returns the initiativesType" do
          expect(response["initiativesType"]).to eq("id" => model.id.to_s)
        end
      end
    end
  end
end
