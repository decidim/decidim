# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/has_publishable_input_filter"

module Decidim
  module Proposals
    describe ProposalInputFilter, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::Proposals::ProposalsType }

      let(:model) { create(:proposal_component) }

      context "when filtered by published at" do
        let!(:models) { create_list(:proposal, 3, :published, component: model) }

        include_examples "has publishable input filter component", "ProposalInputSort", "proposals"
      end
    end
  end
end
