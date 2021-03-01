# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process in the system.
      class CreateParticipatoryProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_participatory_process

          if process.persisted?
            add_admins_as_followers(process)
            link_related_processes
            broadcast(:ok, process)
          else
            form.errors.add(:hero_image, process.errors[:hero_image]) if process.errors.include? :hero_image
            form.errors.add(:banner_image, process.errors[:banner_image]) if process.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :process

        def create_participatory_process
          @process = ParticipatoryProcess.new(
            organization: form.current_organization,
            title: form.title,
            subtitle: form.subtitle,
            weight: form.weight,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            scope_type_max_depth: form.scope_type_max_depth,
            private_space: form.private_space,
            developer_group: form.developer_group,
            local_area: form.local_area,
            area: form.area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope,
            start_date: form.start_date,
            end_date: form.end_date,
            participatory_process_group: form.participatory_process_group
          )

          return process unless process.valid?

          transaction do
            process.save!

            log_process_creation(process)

            process.steps.create!(
              title: TranslationsHelper.multi_translation(
                "decidim.admin.participatory_process_steps.default_title",
                form.current_organization.available_locales
              ),
              active: true
            )

            process
          end
        end

        def log_process_creation(process)
          Decidim::ActionLogger.log(
            "create",
            form.current_user,
            process,
            process.versions.last.id
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
