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

    def level_title
      t "decidim.gamification.level", level: status.level
    end

    def own_profile?
      return @own_profile if defined?(@own_profile)

      @own_profile = if model.is_a?(User)
                       model == current_user
                     elsif model.is_a?(UserGroup) && current_user
                       current_user.user_groups.include?(model)
                     end
    end

    def description
      if own_profile? && status.level.zero?
        score_descriptions[:unearned_own]
      elsif own_profile? && status.level.positive?
        score_descriptions[:description_own]
      elsif !own_profile? && status.level.zero?
        score_descriptions[:unearned_another]
      elsif !own_profile? && status.level.positive?
        score_descriptions[:description_another]
      end
    end

    def tooltip
      if own_profile?
        if status.next_level_in
          t "decidim.gamification.badges.#{badge.name}.next_level_in", score: status.next_level_in
        else
          t "decidim.gamification.reached_top"
        end
      else
        badge.description(controller.current_organization.name)
      end
    end

    def badge_name
      badge.translated_name
    end

    def opacity
      status.level < 1 ? 0.2 : 1
    end

    private

    def score_descriptions
      badge.score_descriptions(status.score)
    end

    def status
      @status ||= options[:status] || Decidim::Gamification.status_for(model, badge.name)
    end
  end
end
