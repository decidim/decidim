# frozen_string_literal: true

module Decidim
  module Gamification
    class BadgesController < Decidim::ApplicationController
      include HasSpecificBreadcrumb

      def index
        @badges = Decidim::Gamification.badges.sort_by(&:name)
      end

      def breadcrumb_item
        {
          label: t("decidim.gamification.badges.index.title"),
          active: true,
          url: gamification_badges_path
        }
      end
    end
  end
end
