# frozen_string_literal: true

namespace :decidim_proposals do
  desc "Set a published_at value to each proposal from the updated_at value"
  task copy_updated_at_to_published_at: :environment do
    Decidim::Proposals::Proposal.all.each do |proposal|
      proposal.update_columns(published_at: proposal.updated_at)
    end
  end
end
