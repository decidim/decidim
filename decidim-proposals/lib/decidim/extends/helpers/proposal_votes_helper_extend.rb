# frozen_string_literal: true

Decidim::Proposals::ProposalVotesHelper.class_eval do
  # Extends for Proposals weighted votes

  # Public: Checks if voting is enabled in this step.
  #
  # Returns true if enabled, false otherwise.
  def votes_enabled?
    current_settings.votes_enabled || current_settings.votes_weight_enabled
  end
end
