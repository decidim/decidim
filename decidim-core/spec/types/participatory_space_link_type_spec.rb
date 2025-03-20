# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe ParticipatorySpaceLinkType, type: :graphql do
      include_context "with a graphql class type"

      let(:organization) { create(:organization) }
      let(:process) { create(:participatory_process, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      # before do

      # end
      let(:model) { ParticipatorySpaceLink.create!(from: assembly, to: process, name: :included_participatory_process) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the links's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the links's name" do
          expect(response["name"]).to eq(model.name)
        end
      end

      describe "fromType" do
        let(:query) { "{ fromType }" }

        it "returns the links's fromType" do
          expect(response["fromType"]).to eq(model.from_type)
        end
      end

      describe "toType" do
        let(:query) { "{ toType }" }

        it "returns the links's toType" do
          expect(response["toType"]).to eq(model.to_type)
        end
      end

      describe "participatorySpace" do
        let(:query) { "{ participatorySpace { id } }" }

        it "returns the links's participatorySpace" do
          expect(response["participatorySpace"]["id"]).to eq(model.to.id.to_s)
          expect(response["participatorySpace"]["id"]).to eq(process.id.to_s)
        end
      end

      context "when link is backwards" do
        let(:model) { ParticipatorySpaceLink.create!(from: process, to: assembly, name: :included_assemblies) }

        describe "participatorySpace" do
          let(:query) { "{ participatorySpace { id } }" }

          it "returns the links's participatorySpace" do
            expect(response["participatorySpace"]["id"]).to eq(model.to.id.to_s)
            expect(response["participatorySpace"]["id"]).to eq(assembly.id.to_s)
          end
        end
      end
    end
  end
end
