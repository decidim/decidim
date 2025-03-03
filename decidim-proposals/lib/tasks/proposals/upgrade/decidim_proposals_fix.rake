# frozen_string_literal: true

namespace :decidim_proposals do
  namespace :fix do
    desc "Fix proposal states created by import from other component bug"
    task fix_state: :environment do
      states_ids_for_reset = []
      Decidim::Proposals::Proposal.unscoped.includes(:proposal_state).where.not(decidim_proposals_proposal_state_id: nil).find_each(batch_size: 100) do |proposal|
        next if proposal.decidim_component_id == proposal.proposal_state.decidim_component_id

        states_ids_for_reset.push(proposal.proposal_state.id)
        new_state = Decidim::Proposals::ProposalState.where(component: proposal.component, token: proposal.proposal_state.token).first
        if new_state.present?
          states_ids_for_reset.push(new_state.id)
          proposal.update_columns(decidim_proposals_proposal_state_id: new_state.id) # rubocop:disable Rails/SkipsModelValidations
        else
          # if the state is not found on the proposal component, the state is custom and should be removed
          proposal.update_columns(decidim_proposals_proposal_state_id: nil) # rubocop:disable Rails/SkipsModelValidations
        end
      end
      states_ids_for_reset.uniq.each do |state_id|
        Decidim::Proposals::ProposalState.reset_counters(state_id, :proposals)
      end
      puts "FINISHED"
    end
  end
end
