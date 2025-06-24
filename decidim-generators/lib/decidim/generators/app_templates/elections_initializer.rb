# frozen_string_literal: true

Decidim::Elections.census_registry.register(:dummy_tokens_census) do |manifest|
  manifest.user_presenter = "Decidim::Elections::Censuses::UserPresenter"

  manifest.user_iterator do |_election, _offset|
    [
      Decidim::Elections::Voter.new(data: { email: "dummy1@example.org", token: "ABC123" }, created_at: 2.days.ago),
      Decidim::Elections::Voter.new(data: { email: "dummy2@example.org", token: "DEF456" }, created_at: 1.day.ago)
    ]
  end

  manifest.census_ready_validator { true }
  manifest.census_counter { 2 }
end
