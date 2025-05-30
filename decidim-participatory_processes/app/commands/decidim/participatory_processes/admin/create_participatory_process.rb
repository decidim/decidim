# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process in the system.
      class CreateParticipatoryProcess < Decidim::Commands::CreateResource
        fetch_file_attributes :hero_image

        fetch_form_attributes :organization, :title, :subtitle, :weight, :slug, :description,
                              :short_description, :promoted, :taxonomizations, :announcement,
                              :private_space, :developer_group, :local_area, :target,
                              :participatory_scope, :participatory_structure, :meta_scope, :start_date, :end_date,
                              :participatory_process_group

        protected

        def run_after_hooks
          create_steps
          add_admins_as_followers
          link_related_processes
          Decidim::ContentBlocksCreator.new(resource).create_default!
        end

        def resource_class = Decidim::ParticipatoryProcess

        def create_steps
          resource.steps.create!(
            title: TranslationsHelper.multi_translation(
              "decidim.admin.participatory_process_steps.default_title",
              form.current_organization.available_locales
            ),
            active: true
          )
        end

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

        def related_processes
          @related_processes ||= Decidim::ParticipatoryProcess.where(id: form.related_process_ids)
        end

        def link_related_processes
          resource.link_participatory_space_resources(related_processes, "related_processes")
        end
      end
    end
  end
end
