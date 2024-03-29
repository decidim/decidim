# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Reject do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create(:amendment, amendable:, emendation:) }
      let(:command) { described_class.new(form) }

      let(:form) { Decidim::Amendable::RejectForm.from_params(form_params).with_context(form_context) }

      let(:form_params) do
        {
          id: amendment.id
        }
      end

      let(:form_context) do
        {
          current_organization: component.organization,
          current_user: amendable.creator_author,
          current_component: component,
          current_participatory_space: component.participatory_space
        }
      end

      include_examples "reject amendment" do
        it "changes the emendation state" do
          not_answered = Decidim::Proposals::ProposalState.where(component:, token: "not_answered").pick(:id)
          rejected = Decidim::Proposals::ProposalState.where(component:, token: "rejected").pick(:id)
          expect { command.call }.to change { emendation.reload[:decidim_proposals_proposal_state_id] }.from(not_answered).to(rejected)
        end
      end
    end
  end
end
