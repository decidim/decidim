# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Proposals
    describe ProposalInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Proposals::ProposalsType }

      let(:model) { create(:proposal_component) }
      let!(:models) { create_list(:proposal, 3, :published, component: model) }

      context "when filtered by published_at" do
        include_examples "connection has before/since input filter", "proposals", "published"
      end
    end
  end
end
