# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::User`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    UserPresenter.new(action_log, view_helpers).present
    class UserPresenter < Decidim::Log::BasePresenter
      private

      def action_string
        case action
        when "grant_id_documents_offline_verification", "invite", "officialize", "remove_from_admin", "show_email", "unofficialize", "block", "unblock", "promote", "transfer"
          "decidim.admin_log.user.#{action}"
        else
          super
        end
      end

      def i18n_params
        super.merge(
          role: I18n.t("models.user.fields.roles.#{user_role}", scope: "decidim.admin")
        )
      end

      def user_role
        Array(action_log.extra.dig("extra", "invited_user_role")).last
      end

      def user_badge
        action_log.extra.dig("extra", "officialized_user_badge") || Hash.new("")
      end

      def previous_user_badge
        action_log.extra.dig("extra", "officialized_user_badge_previous") || Hash.new("")
      end

      def previous_justification
        action_log.extra.dig("extra", "previous_justification") || ""
      end

      def current_justification
        action_log.extra.dig("extra", "current_justification") || Hash.new("")
      end

      # Overwrite the changeset for officialization and block actions.
      def changeset
        original = { badge: [previous_user_badge, user_badge] }
        fields = { badge: :i18n }
        if action.to_s == "block"
          original = { justification: [previous_justification, current_justification] }
          fields = { justification: :string }
        end
        Decidim::Log::DiffChangesetCalculator.new(original, fields, i18n_labels_scope).changeset
      end

      def diff_actions
        %w(officialize unofficialize block)
      end
    end
  end
end
