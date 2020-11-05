# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

      describe "assembliesTypes" do
        let!(:assemblies_type_1) { create(:assemblies_type, organization: current_organization) }
        let!(:assemblies_type_2) { create(:assemblies_type, organization: current_organization) }
        let!(:assemblies_type_3) { create(:assemblies_type) }

        let(:query) { %({ assembliesTypes { id }}) }

        it "returns all the assembliesType" do
          expect(response["assembliesTypes"]).to include("id" => assemblies_type_1.id.to_s)
          expect(response["assembliesTypes"]).to include("id" => assemblies_type_2.id.to_s)
          expect(response["assembliesTypes"]).not_to include("id" => assemblies_type_3.id.to_s)
        end
      end

      describe "assembliesType" do
        let(:query) { %({ assembliesType(id: \"#{id}\") { id }}) }

        context "with a assemblies type that belongs to the current organization" do
          let!(:assemblies_type) { create(:assemblies_type, organization: current_organization) }
          let(:id) { assemblies_type.id }

          it "returns the group" do
            expect(response["assembliesType"]).to eq("id" => assemblies_type.id.to_s)
          end
        end

        context "with a assembliesType of another organization" do
          let!(:assemblies_type) { create(:assemblies_type) }
          let(:id) { assemblies_type.id }

          it "returns nil" do
            expect(response["assembliesType"]).to be_nil
          end
        end
      end
    end
  end
end
