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
          hidden_at: :date,
          report_count: :integer
        }
      end

      def action_string
        case action
        when "hide", "unreport"
          "decidim.admin_log.moderation.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "decidim.moderations.models.moderation.fields"
      end

      def i18n_params
        super.merge(
          resource_type: action_log.extra.dig("extra", "reportable_type").try(:demodulize)
        )
      end

      def diff_actions
        super + %w(unreport)
      end
    end
  end
end
