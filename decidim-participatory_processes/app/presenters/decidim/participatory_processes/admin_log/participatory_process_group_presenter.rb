# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryProcess`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ParticipatoryProcessGroupPresenter.new(action_log, view_helpers).present
      class ParticipatoryProcessGroupPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            developer_group: :i18n,
            hashtag: :string,
            group_url: :string,
            local_area: :i18n,
            meta_scope: :i18n,
            title: :i18n,
            participatory_scope: :i18n,
            participatory_structure: :i18n,
            target: :i18n
          }
        end

        def action_string
          case action
          when "create", "publish", "unpublish", "update"
            "decidim.admin_log.participatory_process_group.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.participatory_process_group"
        end

        def has_diff?
          action == "unpublish" || super
        end
      end
    end
  end
end
