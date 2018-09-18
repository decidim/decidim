# frozen_string_literal: true

module Decidim
  class BadgeCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::IconHelper

    delegate :current_user, to: :controller

    def small
      render "small"
    end

    def badge
      @options[:badge]
    end

    def user
      model
    end

    def level_title
      t "decidim.gamification.level", level: status.level
    end

    def description
      if user == current_user && status.level.zero?
        t "decidim.gamification.badges.#{badge.name}.unearned_own"
      elsif user == current_user && status.level.positive?
        t "decidim.gamification.badges.#{badge.name}.description_own", score: status.score
      elsif user != current_user && status.level.zero?
        t "decidim.gamification.badges.#{badge.name}.unearned_another"
      elsif user != current_user && status.level.positive?
        t "decidim.gamification.badges.#{badge.name}.description_another", score: status.score
      end
    end

    def tooltip
      if user == current_user
        if status.next_level_in
          t "decidim.gamification.badges.#{badge.name}.next_level_in", score: status.next_level_in
        else
          t "decidim.gamification.reached_top"
        end
      else
        t "decidim.gamification.badges.#{badge.name}.explanation"
      end
    end

    def badge_name
      t "decidim.gamification.badges.#{badge.name}.name"
    end

    def opacity
      status.level < 1 ? 0.2 : 1
    end

    private

    def status
      @status ||= options[:status] || Decidim::Gamification.status_for(user, badge.name)
    end
  end
end
