# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Moderation`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ModerationPresenter.new(action_log, view_helpers).present
    class ModerationPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          body: :i18n,
          subject: :i18n
        }
      end

      def action_string
        case action
        when "hide"
          "decidim.admin_log.moderation.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.moderation"
      end

      def i18n_params
        super.merge({
          resource_type: action_log.resource.try(:decidim_reportable_type).try(:demodulize)
        })
      end

      # # Private: Caches the object that will be responsible of presenting the newsletter.
      # # Overwrites the method so that we can use a custom presenter to show the correct
      # # path for the newsletter.
      # #
      # # Returns an object that responds to `present`.
      # def resource_presenter
      #   @resource_presenter ||= Decidim::AdminLog::NewsletterResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
      # end
    end
  end
end
