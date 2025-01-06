# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Moderation`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you should not need to call this class
    # directly, but here is an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ModerationPresenter.new(action_log, view_helpers).present
    class ModerationPresenter < Decidim::Log::BasePresenter
      include Decidim::TranslatableAttributes

      private

      def diff_fields_mapping
        {
          hidden_at: :date,
          report_count: :integer
        }
      end

      def action_string
        case action
        when "hide", "unreport", "bulk_hide", "bulk_unhide", "bulk_unreport"
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
          resource_type: action_log.extra.dig("extra", "reportable_type").try(:demodulize),
          reported_count: action_log.extra.dig("extra", "reported_count") || "?"
        )
      end

      def reported_content
        action_log.extra.dig("extra", "reported_content") || {}
      end

      # Overwrite the changeset.
      def changeset
        types = changeset_config.keys.index_with { |_key| :string }
        Decidim::Log::DiffChangesetCalculator.new(changeset_config, types, "decidim.admin.admin_log.changeset").changeset
      end

      def changeset_config
        reported_content.to_h do |key, items|
          [
            key.to_sym,
            ["", items.values.map { |title| translated_attribute(title) }.join(", ")]
          ]
        end
      end

      # override this as it not depend on the old version
      def has_diff?
        diff_actions.include?(action.to_s) && changeset.any?
      end

      def diff_actions
        super + %w(unreport bulk_hide bulk_unhide bulk_unreport)
      end
    end
  end
end
