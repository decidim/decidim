# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the shared logic for `Decidim::User`
    # presenter for the `AdminLog`.
    class BaseUserPresenter < Decidim::Log::BasePresenter
      private

      def i18n_params
        super.merge(
          blocked_count: blocked_users.count,
          unblocked_count: unblocked_users.count,
          unreported_users_count: unreported_users.count
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

      def current_justification
        action_log.extra.dig("extra", "current_justification") || Hash.new("")
      end

      def changeset
        config = changeset_config[action.to_s]
        return {} unless config

        original = config[:original].call
        return {} if original.values.flatten.all?(&:empty?)

        Decidim::Log::DiffChangesetCalculator.new(original, config[:fields], i18n_labels_scope).changeset
      end

      def changeset_config
        {
          "bulk_block" => {
            original: -> { { justification: [blocked_users.join(", "), current_justification] } },
            fields: { justification: :string }
          },
          "bulk_unblock" => {
            original: -> { { unblocked_users: ["", unblocked_users.join(", ")] } },
            fields: { unblocked_users: :string }
          },
          "bulk_ignore" => {
            original: -> { { unreported_users: ["", unreported_users.join(", ")] } },
            fields: { unreported_users: :string }
          }
        }
      end

      # override this as it not depend on the old version
      def has_diff?
        diff_actions.include?(action.to_s) && changeset.any?
      end
    end
  end
end
