# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/input_sort_examples"

module Decidim
  module Core
    describe ComponentInputSort, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:participatory_process, organization: current_organization) }
      let(:models) { model.components }
      let!(:proposal) { create(:proposal_component, :published, participatory_space: model) }
      let!(:dummy) { create(:component, :published, participatory_space: model) }

      context "when sorting by component id" do
        include_examples "collection has input sort", "components", "id"
      end

      context "when sorting by component name" do
        include_examples "collection has i18n input sort", "components", "name"
      end

      context "when sorting by component weight" do
        before do
          proposal.weight = 3
          proposal.save!
          dummy.weight = 1
          dummy.save!
        end

        include_examples "collection has input sort", "components", "weight"
      end

      context "when sorting by component manifest_name" do
        describe "ASC" do
          let(:query) { %[{ components(order: { type: "ASC" }) { id } }] }

          it "returns alphabetical order" do
            expect(response["components"].first["id"]).to eq(dummy.id.to_s)
            expect(response["components"].last["id"]).to eq(proposal.id.to_s)
          end
        end

        describe "DESC" do
          let(:query) { %[{ components(order: { type: "DESC" }) { id } }] }

          it "returns revered alphabetical order" do
            expect(response["components"].first["id"]).to eq(proposal.id.to_s)
            expect(response["components"].last["id"]).to eq(dummy.id.to_s)
          end
        end
      end
    end
  end
end
