# frozen_string_literal: true

Decidim::Proposals::ProposalCellsHelper.class_eval do
  # Extends for Proposals weighted votes
  def has_actions?
    return context[:has_actions] if context[:has_actions].present?
    proposals_controller? && index_action? && (current_settings.votes_enabled? || current_settings.votes_weight_enabled?) && !model.draft?
  end

  def has_footer?
    return context[:has_footer] if context[:has_footer].present?
    proposals_controller? && index_action? && (current_settings.votes_enabled? || current_settings.votes_weight_enabled?) && !model.draft?
  end
end
