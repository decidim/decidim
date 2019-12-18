# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe ComponentInputFilter, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:proposal_component) }


      describe "type is Proposal" do
        let(:query) {  "{ components(filter: { type: \"Proposal\"}) { id } }" }
        before do
          model.participatory_space.organization = current_organization
          model.participatory_space.save!
        end

        it "returns the component" do
          expect(response["components"]).to eq(model.id)
        end
      end

      describe "type is not Proposal" do
        let(:query) {  "{ components(filter: { type: \"Accountability\"}) { id } }" }

        it "returns the component" do
          expect(response["components"]).to eq([])
        end
      end

      context "when searching components with comments" do

        let(:model_with_comments_enabled) { create(:proposal_component)}
        let(:model_with_comments_disabled) { create(:proposal_component, :with_comments_disabled)}

        describe "comments enabled" do
          let(:query) {  "{ components(filter: { withCommentsEnabled: true} ) { id } }" }

          it "returns the component" do
            expect(response["components"]).to eq(model_with_comments_enabled.id)
          end
        end

        describe "comments not enabled" do
          let(:query) { "{ components(filter: { withCommentsEnabled: true } ) { id } }" }

          it "returns the component" do
            expect(response["components"]).to eq(model_with_comments_disabled.id)
          end
        end
      end

      context "when searching components with geocoding" do

        let(:model_with_geocoding_enabled) { create(:proposal_component, :with_geocoding_enabled)}
        let(:model_with_geocoding_disabled) { create(:proposal_component)}

        describe "comments enabled" do
          let(:query) {  "{ components(filter: { withCommentsEnabled: true} ) { id } }" }

          it "returns the component" do
            expect(response["components"]).to eq(model_with_geocoding_enabled.id)
          end
        end

        describe "comments not enabled" do
          let(:query) { "{ components(filter: { withCommentsEnabled: false } ) { id } }" }

          it "returns the component" do
            expect(response["components"]).to eq(model_with_geocoding_disabled.id)
          end
        end
      end
    end
  end
end
