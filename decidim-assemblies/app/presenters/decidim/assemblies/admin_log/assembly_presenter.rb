# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      # This class holds the logic to present a `Decidim::Assembly`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    AssemblyPresenter.new(action_log, view_helpers).present
      class AssemblyPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            hashtag: :string,
            decidim_area_id: :area,
            decidim_scope_id: :scope,
            developer_group: :i18n,
            local_area: :i18n,
            meta_scope: :i18n,
            participatory_scope: :i18n,
            participatory_structure: :i18n,
            promoted: :boolean,
            published_at: :date,
            reference: :string,
            scopes_enabled: :boolean,
            short_description: :i18n,
            show_statistics: :boolean,
            slug: :default,
            subtitle: :i18n,
            target: :i18n,
            title: :i18n
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.assembly"
        end

        def action_string
          case action
          when "create", "publish", "unpublish", "update"
            "decidim.admin_log.assembly.#{action}"
          else
            super
          end
        end

        def has_diff?
          action == "unpublish" || super
        end
      end
    end
  end
end
