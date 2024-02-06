# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Accept do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create(:amendment, amendable:, emendation:) }
      let(:command) { described_class.new(form) }

      let(:emendation_params) do
        {
          title: translated(emendation.title),
          body: translated(emendation.body)
        }
      end

      let(:form_params) do
        {
          id: amendment.id,
          emendation_params:
        }
      end

      let(:form) { Decidim::Amendable::ReviewForm.from_params(form_params) }

      include_examples "accept amendment" do
        it "changes the emendation state" do
          not_answered = Decidim::Proposals::ProposalState.where(component:, token: "not_answered").pick(:id)
          accepted = Decidim::Proposals::ProposalState.where(component:, token: "accepted").pick(:id)
          expect { command.call }.to change { emendation.reload[:decidim_proposals_proposal_state_id] }.from(not_answered).to(accepted)
        end
      end
    end
  end
end
