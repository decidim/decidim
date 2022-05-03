# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module AdminLog
      # This class holds the logic to present a
      # `Decidim::ParticipatoryProcessType`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ParticipatoryProcessTypePresenter.new(action_log, view_helpers).present
      class ParticipatoryProcessTypePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          { title: :i18n }
        end

        def action_string
          case action
          when "create", "update"
            "decidim.admin_log.participatory_process_type.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.participatory_process_type"
        end
      end
    end
  end
end
