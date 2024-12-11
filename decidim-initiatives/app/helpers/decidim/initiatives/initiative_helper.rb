# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper method related to initiative object and its internal state.
    module InitiativeHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceVersionsHelper

      def metadata_badge_css_class(initiative)
        case initiative
        when "accepted", "open"
          "success"
        when "rejected", "discarded"
          "alert"
        when "validating"
          "warning"
        else
          "muted"
        end
      end

      # Public: The state of an initiative from an administration perspective in
      # a way that a human can understand.
      #
      # state - String
      #
      # Returns a String
      def humanize_admin_state(state)
        I18n.t(state, scope: "decidim.initiatives.admin_states", default: :created)
      end

      def can_edit_custom_signature_end_date?(initiative)
        return false unless initiative.custom_signature_end_date_enabled?

        initiative.created? || initiative.validating?
      end

      def render_committee_tooltip
        with_tooltip t("decidim.initiatives.create_initiative.share_committee_link.invite_to_committee_help"), class: "left" do
          icon "file-copy-line"
        end
      end

      def hero_background_path(initiative)
        initiative.attachments.find(&:image?)&.url
      end
    end
  end
end
