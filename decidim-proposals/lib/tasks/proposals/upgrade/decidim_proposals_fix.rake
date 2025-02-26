# frozen_string_literal: true

namespace :decidim_proposals do
  namespace :fix do
    desc "Fix proposal states created by import from other component bug"
    task state: :environment do
      states_ids_for_reset = []
      Decidim::Proposals::Proposal.unscoped.includes(:proposal_state).where.not(decidim_proposals_proposal_state_id: nil).find_each do |proposal|
        next if proposal.decidim_component_id == proposal.proposal_state.decidim_component_id

        states_ids_for_reset.push(proposal.proposal_state.id)
        if proposal.state_published_at.present?
          new_state = Decidim::Proposals::ProposalState.where(component: proposal.component, token: proposal.proposal_state.token).first
          states_ids_for_reset.push(new_state.id)
          proposal.update_columns(decidim_proposals_proposal_state_id: new_state.id) # rubocop:disable Rails/SkipsModelValidations
        else
          proposal.update_columns(decidim_proposals_proposal_state_id: nil) # rubocop:disable Rails/SkipsModelValidations
        end
      end
      puts "reset counters" if states_ids_for_reset.any?
      states_ids_for_reset.uniq.each do |state_id|
        Decidim::Proposals::ProposalState.reset_counters(state_id, :proposals)
      end
      puts "FINISHED"
    end
  end
end
