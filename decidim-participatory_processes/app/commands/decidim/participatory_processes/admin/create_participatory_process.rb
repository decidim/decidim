# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process in the system.
      class CreateParticipatoryProcess < Decidim::Commands::CreateResource
        fetch_form_attributes :organization, :title, :subtitle, :weight, :slug, :hashtag, :description,
                              :short_description, :hero_image, :banner_image, :promoted, :scopes_enabled, :scope,
                              :scope_type_max_depth, :private_space, :developer_group, :local_area, :area, :target,
                              :participatory_scope, :participatory_structure, :meta_scope, :start_date, :end_date,
                              :participatory_process_group, :participatory_process_type, :show_metrics,
                              :show_statistics, :announcement

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if process.persisted?
            create_steps
            add_admins_as_followers(process)
            link_related_processes
            Decidim::ContentBlocksCreator.new(process).create_default!

            broadcast(:ok, process)
          else
            form.errors.add(:hero_image, process.errors[:hero_image]) if process.errors.include? :hero_image
            form.errors.add(:banner_image, process.errors[:banner_image]) if process.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        protected

        def resource_class = Decidim::ParticipatoryProcess

        def process
          @process ||= create_resource(soft: true)
        end

        def create_steps
          process.steps.create!(
            title: TranslationsHelper.multi_translation(
              "decidim.admin.participatory_process_steps.default_title",
              form.current_organization.available_locales
            ),
            active: true
          )
        end

        def add_admins_as_followers(process)
          process.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: process.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: process.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

        def related_processes
          @related_processes ||= Decidim::ParticipatoryProcess.where(id: form.related_process_ids)
        end

        def link_related_processes
          process.link_participatory_space_resources(related_processes, "related_processes")
        end
      end
    end
  end
end
