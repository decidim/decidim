# frozen_string_literal: true

namespace :decidim_proposals do
  namespace :upgrade do
    desc "Assigns category to emendations based on amendable category"
    task set_categories: :environment do
      Decidim::Proposals::Proposal.includes(:category).find_each do |proposal|
        next if proposal.category.blank?
        next unless proposal.amendable?

        proposal.emendations.each do |emendation|
          emendation.category = proposal.category
          emendation.save(validate: false)
        end
      end
    end

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

    desc "Removes all proposal evaluator records of which the role assignment does not exists"
    task remove_evaluator_orphan_records: :environment do
      if Decidim.module_installed?("participatory_processes")
        Decidim::Proposals::EvaluationAssignment
          .where(evaluator_role_type: "Decidim::ParticipatoryProcessUserRole")
          .where
          .not(evaluator_role_id: Decidim::ParticipatoryProcessUserRole.pluck(:id))
          .destroy_all
      end

      if Decidim.module_installed?("assemblies")
        Decidim::Proposals::EvaluationAssignment
          .where(evaluator_role_type: "Decidim::AssemblyUserRole")
          .where
          .not(evaluator_role_id: Decidim::AssemblyUserRole.pluck(:id))
          .destroy_all
      end

      if Decidim.module_installed?("conferences")
        Decidim::Proposals::EvaluationAssignment
          .where(evaluator_role_type: "Decidim::ConferenceUserRole")
          .where
          .not(evaluator_role_id: Decidim::ConferenceUserRole.pluck(:id))
          .destroy_all
      end
    end
  end
end
