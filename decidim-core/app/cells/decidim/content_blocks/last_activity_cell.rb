# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the latest activities performed
    # in a Decidim Organization.
    class LastActivityCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers

      def show
        return if valid_activities.empty?

        render
      end

      # The activities to be displayed at the content block.
      #
      # We need to build the collection this way because an ActionLog has
      # polymorphic relations to different kind of models, and these models
      # might not be available (a proposal might have been hidden or withdrawn).
      #
      # Since these conditions can't always be filtered with a database search
      # we ask for more activities than we actually need and then loop until there
      # are enough of them.
      #
      # Returns an Array of ActionLogs.
      def valid_activities
        return @valid_activities if defined?(@valid_activities)

        valid_activities_count = 0
        @valid_activities = []

        activities.each do |activity|
          break if valid_activities_count == activities_to_show

          if activity.resource_lazy.present? && activity.participatory_space_lazy.present? && visible_for_user?(activity)
            @valid_activities << activity
            valid_activities_count += 1
          end
        end

        @valid_activities
      end

      private

      def visible_for_user?(activity)
        return true unless activity.resource_lazy.respond_to?(:can_participate?)

        activity.resource_lazy.can_participate?(current_user)
      end

      def activities
        @activities ||= HomeActivitySearch.new(
          organization: current_organization,
          resource_type: "all"
        ).results.limit(activities_to_show * 6)
      end

      def activities_to_show
        options[:activities_count] || 8
      end
    end
  end
end
