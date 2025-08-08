# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # in the system.
      class CreateAssembly < Decidim::Commands::CreateResource
        fetch_file_attributes :hero_image, :banner_image

        fetch_form_attributes :title, :subtitle, :weight, :slug, :description, :short_description,
                              :promoted, :taxonomizations, :parent, :announcement, :organization,
                              :private_space, :developer_group, :local_area, :target, :participatory_scope,
                              :participatory_structure, :meta_scope, :purpose_of_action,
                              :composition, :creation_date, :created_by, :created_by_other,
                              :duration, :included_at, :closing_date, :closing_date_reason, :internal_organisation,
                              :is_transparent, :special_features, :twitter_handler, :facebook_handler,
                              :instagram_handler, :youtube_handler, :github_handler

        protected

        def run_after_hooks
          add_admins_as_followers
          link_participatory_processes
          Decidim::ContentBlocksCreator.new(resource).create_default!
        end

        private

        def resource_class = Decidim::Assembly

        def add_admins_as_followers
          resource.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: resource.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: resource.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form).call
          end
        end

        def participatory_processes
          @participatory_processes ||= resource.participatory_space_sibling_scope(:participatory_processes).where(id: form.participatory_processes_ids)
        end

        def link_participatory_processes
          resource.link_participatory_space_resources(participatory_processes, "included_participatory_processes")
        end
      end
    end
  end
end
