# frozen_string_literal: true

module Decidim
  module Gamification
    class BadgesController < Decidim::ApplicationController
      def index
        @badges = Decidim::Gamification.badges.sort_by(&:name)
      end
    end
  end
end
