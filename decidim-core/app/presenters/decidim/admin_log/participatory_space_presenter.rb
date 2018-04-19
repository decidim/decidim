# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::ParticipatorySpace`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ParticipatorySpacePresenter.new(action_log, view_helpers).present
    class ParticipatorySpacePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          activated_at: :date,
          published_at: :date
        }
      end

      def action_string
        case action
        when "activate", "deactivate", "publish", "unpublished"
          "decidim.admin_log.participatory_space.#{action}"
        else
          super
        end
      end

      # Private: Caches the object that will be responsible of presenting the participatory space.
      # Overwrites the method so that we can use a custom presenter to show the correct
      # path for the space.
      #
      # Returns an object that responds to `present`.
      def resource_presenter
        @resource_presenter ||= Decidim::AdminLog::ParticipatorySpaceResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
      end

      def i18n_labels_scope
        "activemodel.attributes.participatory_space"
      end

      def has_diff?
        ["activate", "deactivate"].include? action
      end
    end
  end
end
