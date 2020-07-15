# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

      describe "assembliesTypes" do
        let!(:assembliesType1) { create(:assemblies_type, organization: current_organization) }
        let!(:assembliesType2) { create(:assemblies_type, organization: current_organization) }
        let!(:assembliesType3) { create(:assemblies_type) }

        let(:query) { %({ assembliesTypes { id }}) }

        it "returns all the assembliesType" do
          expect(response["assembliesTypes"]).to include("id" => assembliesType1.id.to_s)
          expect(response["assembliesTypes"]).to include("id" => assembliesType2.id.to_s)
          expect(response["assembliesTypes"]).not_to include("id" => assembliesType3.id.to_s)
        end
      end

      describe "assembliesType" do
        let(:query) { %({ assembliesType(id: \"#{id}\") { id }}) }

        context "with a assemblies type that belongs to the current organization" do
          let!(:assembliesType) { create(:assemblies_type, organization: current_organization) }
          let(:id) { assembliesType.id }

          it "returns the group" do
            expect(response["assembliesType"]).to eq("id" => assembliesType.id.to_s)
          end
        end

        context "with a assembliesType of another organization" do
          let!(:assembliesType) { create(:assemblies_type) }
          let(:id) { assembliesType.id }

          it "returns nil" do
            expect(response["assembliesType"]).to be_nil
          end
        end
      end
    end
  end
end
