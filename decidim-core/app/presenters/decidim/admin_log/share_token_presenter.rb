# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class extends the default resource presenter for logs, so that
    # it can properly link to the static page.
    class ShareTokenPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          token: :string,
          expires_at: :date,
          registered_only: :boolean,
          token_for: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.share_token.#{action}#{suffix}"
        else
          super
        end
      end

      def suffix
        return "_with_space" if action_log.extra.dig("component", "title").present?

        ""
      end

      def diff_actions
        %w(update create delete)
      end
    end
  end
end
