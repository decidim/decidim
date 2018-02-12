Decidim::Proposals::Proposal.class_eval do
  def vote_weight_enabled?
    feature.settings.vote_weight_enabled
  end
end