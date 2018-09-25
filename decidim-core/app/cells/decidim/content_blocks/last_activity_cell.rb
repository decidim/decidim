# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LastActivityCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers

      delegate :current_organization, to: :controller

      def show
        return if activities.empty?
        render
      end

      def valid_activities
        return @valid_activities if defined?(@valid_activities)

        valid_activities_count = 0
        @valid_activities = []

        activities.each do |activity|
          break if valid_activities_count == 8
          if activity.resource_lazy.present? && activity.participatory_space_lazy.present?
            @valid_activities << activity
            valid_activities_count += 1
          end
        end

        @valid_activities
      end

      def activities
        @activities ||= ActivitySearch.new(
          organization: current_organization,
          resource_type: "all"
        ).results.limit(50)
      end
    end
  end
end
