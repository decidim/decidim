# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      # This class holds the logic to present a `Decidim::AssembliesSetting`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    AssembliesSettingPresenter.new(action_log, view_helpers).present
      class AssembliesSettingPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.assemblies_setting"
        end

        def action_string
          case action
          when "update"
            "decidim.admin_log.assembly_setting.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
