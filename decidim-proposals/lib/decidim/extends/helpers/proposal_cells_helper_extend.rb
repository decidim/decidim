# frozen_string_literal: true


Decidim::Proposals::ProposalCellsHelper.class_eval do
  # Extends for Proposals weighted votes

  def actionable?
    proposals_controller? && index_action? && (current_settings.votes_enabled? || current_settings.votes_weight_enabled?) && !model.draft?
  end

end
