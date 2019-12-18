# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe ComponentInputFilter, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:participatory_process, organization: current_organization) }
      let!(:proposal) { create(:proposal_component, :published, participatory_space: model) }
      let!(:dummy) { create(:component, :published, participatory_space: model) }


      context "when no filters are applied" do
        let(:query) {  %[{ components(filter: {}) { id } }] }
        it "returns all the types" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
          expect(ids).to include(*dummy.id)
        end
      end

      context "when filtering by type" do
        let(:query) {  %[{ components(filter: { type: "proposals"}) { id } }] }

        it "returns the types requested" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
          expect(ids).not_to include(*dummy.id)
        end
      end

      context "when type is not present" do
        let(:query) {  %[{ components(filter: { type: "other_type"}) { id } }] }

        it "returns and empty array" do
          expect(response["components"]).to eq([])
        end
      end

      # context "when searching components with comments" do

      #   let(:model_with_comments_enabled) { create(:proposal_component)}
      #   let(:model_with_comments_disabled) { create(:proposal_component, :with_comments_disabled)}

      #   describe "comments enabled" do
      #     let(:query) {  "{ components(filter: { withCommentsEnabled: true} ) { id } }" }

      #     it "returns the component" do
      #       expect(response["components"]).to eq(model_with_comments_enabled.id)
      #     end
      #   end

      #   describe "comments not enabled" do
      #     let(:query) { "{ components(filter: { withCommentsEnabled: true } ) { id } }" }

      #     it "returns the component" do
      #       expect(response["components"]).to eq(model_with_comments_disabled.id)
      #     end
      #   end
      # end

      # context "when searching components with geocoding" do

      #   let(:model_with_geocoding_enabled) { create(:proposal_component, :with_geocoding_enabled)}
      #   let(:model_with_geocoding_disabled) { create(:proposal_component)}

      #   describe "comments enabled" do
      #     let(:query) {  "{ components(filter: { withCommentsEnabled: true} ) { id } }" }

      #     it "returns the component" do
      #       expect(response["components"]).to eq(model_with_geocoding_enabled.id)
      #     end
      #   end

      #   describe "comments not enabled" do
      #     let(:query) { "{ components(filter: { withCommentsEnabled: false } ) { id } }" }

      #     it "returns the component" do
      #       expect(response["components"]).to eq(model_with_geocoding_disabled.id)
      #     end
      #   end
      # end
    end
  end
end
