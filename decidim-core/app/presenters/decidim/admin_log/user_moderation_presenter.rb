# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::UserModeration`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ModerationPresenter.new(action_log, view_helpers).present
    class UserModerationPresenter < Decidim::Log::BasePresenter
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
          "decidim.admin_log.user_moderation.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "decidim.moderations.models.moderation.fields"
      end

      def i18n_params
        super.merge(
          resource_type: action_log.extra.dig("extra", "reportable_type").try(:demodulize),
          unreported_user_name: unreported_user_presenter.try(:present)
        )
      end

      # Private: Caches the object that will be responsible of presenting the user
      # that performed the given action.
      #
      # Returns an object that responds to `present`.
      def unreported_user_presenter
        @unreported_user_presenter ||= Decidim::Log::UserPresenter.new(unreported_user, h,
                                                                       "name" => unreported_user.name,
                                                                       "nickname" => unreported_user.nickname)
      end

      def unreported_user
        @unreported_user ||= Decidim::User.find_by(id: action_log.extra.dig("extra", "user_id"))
      end

      def has_diff?
        action == "unreport" || super
      end
    end
  end
end
