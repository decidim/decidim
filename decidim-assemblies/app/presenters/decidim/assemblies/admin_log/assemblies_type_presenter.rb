# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      # This class holds the logic to present a `Decidim::AssembliesType`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    AssembliesTypePresenter.new(action_log, view_helpers).present
      class AssembliesTypePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.assemblies_type"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.assembly_type.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
