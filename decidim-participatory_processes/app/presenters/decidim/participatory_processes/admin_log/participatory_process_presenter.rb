# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryProcess`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ParticipatoryProcessPresenter.new(action_log, view_helpers).present
      class ParticipatoryProcessPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            developer_group: :i18n,
            decidim_area_id: :area,
            local_area: :i18n,
            meta_scope: :i18n,
            participatory_scope: :i18n,
            participatory_structure: :i18n,
            published_at: :date,
            scopes_enabled: :boolean,
            short_description: :i18n,
            slug: :string,
            subtitle: :i18n,
            target: :i18n,
            title: :i18n,
            decidim_participatory_process_type_id: :participatory_process_type
          }
        end

        def action_string
          case action
          when "create", "publish", "unpublish", "update", "import", "export", "duplicate", "soft_delete", "restore"
            "decidim.admin_log.participatory_process.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.participatory_process"
        end

        def diff_actions
          super + %w(unpublish)
        end
      end
    end
  end
end
