# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      # This class holds the logic to present a `Decidim::Assembly`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    AssemblyPresenter.new(action_log, view_helpers).present
      class AssemblyPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
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
            slug: :default,
            subtitle: :i18n,
            target: :i18n,
            title: :i18n,
            purpose_of_action: :i18n,
            decidim_assemblies_type_id: :assembly_type,
            creation_date: :date,
            created_by: :string,
            created_by_other: :i18n,
            duration: :date,
            included_at: :date,
            closing_date: :date,
            closing_date_reason: :i18n,
            internal_organisation: :i18n,
            is_transparent: :boolean,
            special_features: :i18n,
            twitter_handler: :string,
            facebook_handler: :string,
            instagram_handler: :string,
            youtube_handler: :string,
            github_handler: :string,
            parent_id: :assembly
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.assembly"
        end

        def action_string
          case action
          when "create", "publish", "unpublish", "update", "duplicate", "export", "import", "soft_delete", "restore"
            "decidim.admin_log.assembly.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(unpublish)
        end
      end
    end
  end
end
