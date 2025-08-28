# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating a new assembly
      # in the system.
      class UpdateAssembly < Decidim::Commands::UpdateResource
        fetch_file_attributes :hero_image, :banner_image

        fetch_form_attributes :title, :subtitle, :slug, :promoted, :description, :short_description,
                              :taxonomizations, :parent, :private_space, :developer_group, :local_area,
                              :target, :participatory_scope, :participatory_structure, :meta_scope,
                              :purpose_of_action, :composition, :creation_date, :created_by,
                              :created_by_other, :duration, :included_at, :closing_date, :closing_date_reason,
                              :internal_organisation, :is_transparent, :special_features, :twitter_handler, :announcement,
                              :facebook_handler, :instagram_handler, :youtube_handler, :github_handler, :weight

        private

        def run_after_hooks
          link_participatory_processes
          update_children_count
        end

        def parent
          @parent ||= Assembly.find_by(id: resource.parent)
        end

        def participatory_processes
          @participatory_processes ||= resource.participatory_space_sibling_scope(:participatory_processes).where(id: form.participatory_processes_ids)
        end

        def link_participatory_processes
          resource.link_participatory_space_resources(participatory_processes, "included_participatory_processes")
        end

        # Resets the children counter cache to its correct value using an SQL count query.
        # Fixes Rails decrementing twice error when updating the parent to nil.
        #
        # Returns nothing.
        def update_children_count
          return unless parent

          Assembly.reset_counters(parent.id, :children_count)
        end
      end
    end
  end
end
