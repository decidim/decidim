# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "assembliesTypes" do
        let!(:assemblies_type1) { create(:assemblies_type, organization: current_organization) }
        let!(:assemblies_type2) { create(:assemblies_type, organization: current_organization) }
        let!(:assemblies_type3) { create(:assemblies_type) }

        let(:query) { %({ assembliesTypes { id }}) }

        it "returns all the assembliesType" do
          expect(response["assembliesTypes"]).to include("id" => assemblies_type1.id.to_s)
          expect(response["assembliesTypes"]).to include("id" => assemblies_type2.id.to_s)
          expect(response["assembliesTypes"]).not_to include("id" => assemblies_type3.id.to_s)
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

      describe "assemblies" do
        let!(:assembly1) { create(:assembly, organization: current_organization) }
        let!(:assembly2) { create(:assembly, organization: current_organization) }
        let!(:assembly3) { create(:assembly) }

        let(:query) { %({ assemblies { id }}) }

        it "returns all the assemblyes" do
          expect(response["assemblies"]).to include("id" => assembly1.id.to_s)
          expect(response["assemblies"]).to include("id" => assembly2.id.to_s)
          expect(response["assemblies"]).not_to include("id" => assembly3.id.to_s)
        end
      end

      describe "assembly" do
        let(:query) { %({ assembly(id: \"#{id}\") { id }}) }

        context "with a participatory assembly that belongs to the current organization" do
          let!(:assembly) { create(:assembly, organization: current_organization) }
          let(:id) { assembly.id }

          it "returns the assembly" do
            expect(response["assembly"]).to eq("id" => assembly.id.to_s)
          end
        end

        context "with a participatory assembly of another organization" do
          let!(:assembly) { create(:assembly) }
          let(:id) { assembly.id }

          it "returns nil" do
            expect(response["assembly"]).to be_nil
          end
        end
      end
    end
  end
end
