# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe ComponentInputFilter, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:proposal_component, organization: current_organization) }

      describe "type is Proposal" do
        let(:query) {  "{ components(filter: { type: \"Proposal\"}) { id } }" }

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
    end
  end
end
