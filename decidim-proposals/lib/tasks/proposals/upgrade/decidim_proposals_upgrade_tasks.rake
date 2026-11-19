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

    desc "Fix proposal statuses created by import from other component bug"
    task fix_status: :environment do
      statuses_ids_for_reset = []
      Decidim::Proposals::Proposal.unscoped.includes(:proposal_status).where.not(decidim_proposals_proposal_status_id: nil).find_each(batch_size: 100) do |proposal|
        next if proposal.decidim_component_id == proposal.proposal_status.decidim_component_id

        statuses_ids_for_reset.push(proposal.proposal_status.id)
        new_status = Decidim::Proposals::ProposalStatus.where(component: proposal.component, token: proposal.proposal_status.token).first
        if new_status.present?
          statuses_ids_for_reset.push(new_status.id)
          proposal.update_columns(decidim_proposals_proposal_status_id: new_status.id) # rubocop:disable Rails/SkipsModelValidations
        else
          # if the status is not found on the proposal component, the status is custom and should be removed
          proposal.update_columns(decidim_proposals_proposal_status_id: nil) # rubocop:disable Rails/SkipsModelValidations
        end
      end
      statuses_ids_for_reset.uniq.each do |status_id|
        Decidim::Proposals::ProposalStatus.reset_counters(status_id, :proposals)
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
