# frozen_string_literal: true

module Decidim
  class BadgesCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers

    def available_badges
      Decidim::Gamification.badges.select do |badge|
        badge.valid_for?(model)
      end.sort_by(&:name)
    end
  end
end
