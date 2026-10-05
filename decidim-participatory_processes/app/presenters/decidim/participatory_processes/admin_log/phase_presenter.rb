# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module AdminLog
      # This class holds the logic to present a `Decidim::Phase`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PhasePresenter.new(action_log, view_helpers).present
      class PhasePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            title: :i18n
          }
        end

        def action_string
          case action
          when "activate", "create", "delete", "update"
            "decidim.admin_log.participatory_process_phase.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.participatory_process_phase"
        end
      end
    end
  end
end
