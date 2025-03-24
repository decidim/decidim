# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Component`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you should not need to call this class
    # directly, but here is an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ComponentPresenter.new(action_log, view_helpers).present
    class ComponentPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :i18n,
          published_at: :date,
          weight: :integer,
          permissions: :jsonb
        }
      end

      def i18n_labels_scope
        "activemodel.attributes.component"
      end

      def action_string
        case action
        when "export_component", "soft_delete", "restore"
          "decidim.admin_log.component.#{action}"
        when "create", "delete", "publish", "unpublish", "update_permissions", "update_filters"
          generate_action_string(action)
        else
          super
        end
      end

      def generate_action_string(action)
        string = if action_log.participatory_space.present?
                   "#{action}_with_space"
                 else
                   action
                 end
        "decidim.log.base_presenter.#{string}"
      end

      def diff_actions
        super + %w(unpublish update_permissions update_filters)
      end

      def i18n_params
        case action_log.extra["name"]
        when "proposal_comments", "result_comments", "comments", "meeting_comments"
          super.merge({
                        component_name: I18n.t("decidim.admin_log.helpers.comments"),
                        format_name: action_log.extra["format"]
                      })
        when "projects", "results", "answers"
          super.merge({
                        component_name: I18n.t("decidim.admin_log.helpers.#{action_log.extra["name"]}"),
                        format_name: action_log.extra["format"]
                      })
        else
          super.merge({
                        component_name: "",
                        format_name: action_log.extra["format"]
                      })
        end
      end

      def changeset
        changes = action_log.version.changeset
        mapping = diff_fields_mapping
        if action == "update_filters"
          changes = {
            "taxonomy_filters" => [
              filters_for(action_log.version.changeset["settings"].first.dig("global", "taxonomy_filters")),
              filters_for(action_log.version.changeset["settings"].last.dig("global", "taxonomy_filters"))
            ]
          }
          mapping = { taxonomy_filters: :array }
        end
        Decidim::Log::DiffChangesetCalculator.new(
          changes,
          mapping,
          i18n_labels_scope
        ).changeset
      end

      def filters_for(ids)
        return [] if ids.blank?

        @filters_ids ||= {}
        ids.map do |id|
          @filters_ids[id] ||= Decidim::TaxonomyFilter.find_by(id: ids)
          @filters_ids[id] ? "#{id}: #{@filters_ids[id].translated_internal_name}" : id
        end
      end
    end
  end
end
