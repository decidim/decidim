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
      # Since these conditions cannot always be filtered with a database search
      # we ask for more activities than we actually need and then loop until there
      # are enough of them.
      #
      # Returns an Array of ActionLogs.
      def valid_activities
        return @valid_activities if defined?(@valid_activities)

        valid_activities_count = 0
        @valid_activities = []

        activities.includes([:user]).each do |activity|
          break if valid_activities_count == activities_to_show

          if activity.visible_for?(current_user)
            @valid_activities << activity
            valid_activities_count += 1
          end
        end

        @valid_activities
      end

      private

      # A MD5 hash of model attributes because is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/last_activity"
        hash << Digest::SHA256.hexdigest(valid_activities.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join(Decidim.cache_key_separator)
      end

      def activities
        @activities ||= Decidim::LastActivity.new(current_organization, current_user:).query.limit(activities_to_show * 6)
      end

      def activities_to_show
        options[:activities_count] || 8
      end
    end
  end
end
