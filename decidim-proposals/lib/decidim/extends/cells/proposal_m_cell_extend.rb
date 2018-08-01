# frozen_string_literal: true

Decidim::Proposals::ProposalMCell.class_eval do
  # Extends for Proposals weighted votes
  def progress_bar_subtitle_text
    tr_path = current_settings.votes_weight_enabled? ? "votes_weight" : "votes_count"
    if progress_bar_progress >= progress_bar_total
      t("decidim.proposals.proposals.#{tr_path}.most_popular_proposal")
    else
      t("decidim.proposals.proposals.#{tr_path}.need_more_votes")
    end
  end
end
