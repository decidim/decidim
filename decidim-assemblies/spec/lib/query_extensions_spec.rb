# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "assemblies" do
        let!(:assembly1) { create(:assembly, organization: current_organization) }
        let!(:assembly2) { create(:assembly, organization: current_organization) }
        let!(:assembly3) { create(:assembly) }

        let(:query) { %({ assemblies { id }}) }

        it "returns all the assemblies" do
          expect(response["assemblies"]).to include("id" => assembly1.id.to_s)
          expect(response["assemblies"]).to include("id" => assembly2.id.to_s)
          expect(response["assemblies"]).not_to include("id" => assembly3.id.to_s)
        end
      end

      describe "assembly" do
        let(:query) { %({ assembly(id: "#{id}") { id }}) }

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
