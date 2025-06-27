# frozen_string_literal: true

Decidim::Elections.census_registry.register(:dummy_tokens_census) do |manifest|
  manifest.user_presenter = "Decidim::Elections::Censuses::UserPresenter"

  manifest.user_query do |election|
    Decidim::Elections::Voter.where(election:)
  end
end
