# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::User`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you should not need to call this class
    # directly, but here is an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    UserPresenter.new(action_log, view_helpers).present
    class UserPresenter < Decidim::Log::BasePresenter
      private

      def action_string
        case action
        when "grant_id_documents_offline_verification", "invite", "officialize", "remove_from_admin",
              "show_email", "unofficialize", "block", "unblock", "bulk_block", "bulk_unblock", "promote", "transfer", "bulk_ignore", "bulk_hide", "bulk_unreport", "bulk_unhide"
          "decidim.admin_log.user.#{action}"
        else
          super
        end
      end

      def i18n_params
        super.merge(
          role: I18n.t("models.user.fields.roles.#{user_role}", scope: "decidim.admin"),
          blocked_count: blocked_users.count,
          unblocked_count: unblocked_users.count,
          unreported_users_count: unreported_users.count,
          hidden_count: hidden_content.count,
          unhidden_count: unhidden_content.count,
          unreported_count: unreported_content.count
        )
      end

      def blocked_users
        action_log.extra.dig("extra", "blocked")&.values || []
      end

      def unblocked_users
        action_log.extra.dig("extra", "unblocked")&.values || []
      end

      def unreported_users
        action_log.extra.dig("extra", "unreported")&.values || []
      end

      def hidden_content
        action_log.extra.dig("extra", "reported_content")&.values || []
      end

      def unhidden_content
        action_log.extra.dig("extra", "reported_content")&.values || []
      end

      def unreported_content
        action_log.extra.dig("extra", "reported_content")&.values || []
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
        case action.to_s
        when "block"
          original = { justification: [previous_justification, current_justification] }
          fields = { justification: :string }
        when "bulk_block"
          original = { justification: [blocked_users.join(", "), current_justification] }
          fields = { justification: :string }
        when "bulk_unblock"
          original = { unblocked_users: ["", unblocked_users.join(", ")] }
          fields = { unblocked_users: :string }
        when "bulk_ignore"
          original = { unreported_users: ["", unreported_users.join(", ")] }
          fields = { unreported_users: :string }
        when "bulk_hide"
          original = { hidden_content: ["", hidden_content.join(", ")] }
          fields = { hidden_content: :string }
        when "bulk_unreport"
          original = { unreported_content: ["", unreported_content.join(", ")] }
          fields = { unreported_content: :string }
        when "bulk_unhide"
          original = { unhidden_content: ["", unhidden_content.join(", ")] }
          fields = { unhidden_content: :string }
        end
        Decidim::Log::DiffChangesetCalculator.new(original, fields, i18n_labels_scope).changeset
      end

      # override this as it not depend on the old version
      def has_diff?
        diff_actions.include?(action.to_s)
      end

      def diff_actions
        %w(officialize unofficialize block bulk_block bulk_unblock bulk_ignore bulk_hide bulk_unreport bulk_unhide)
      end
    end
  end
end
