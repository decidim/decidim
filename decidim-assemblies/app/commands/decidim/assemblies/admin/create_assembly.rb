# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # assembly in the system.
      class CreateAssembly < Rectify::Command
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

          if assembly.persisted?
            add_admins_as_followers(assembly)
            link_participatory_processes(assembly)

            broadcast(:ok, assembly)
          else
            form.errors.add(:hero_image, assembly.errors[:hero_image]) if assembly.errors.include? :hero_image
            form.errors.add(:banner_image, assembly.errors[:banner_image]) if assembly.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def assembly
          @assembly ||= Decidim.traceability.create(
            Assembly,
            form.current_user,
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
            area: form.area,
            parent: form.parent,
            private_space: form.private_space,
            developer_group: form.developer_group,
            local_area: form.local_area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope,
            show_statistics: form.show_statistics,
            purpose_of_action: form.purpose_of_action,
            composition: form.composition,
            assembly_type: form.assembly_type,
            creation_date: form.creation_date,
            created_by: form.created_by,
            created_by_other: form.created_by_other,
            duration: form.duration,
            included_at: form.included_at,
            closing_date: form.closing_date,
            closing_date_reason: form.closing_date_reason,
            internal_organisation: form.internal_organisation,
            is_transparent: form.is_transparent,
            special_features: form.special_features,
            twitter_handler: form.twitter_handler,
            facebook_handler: form.facebook_handler,
            instagram_handler: form.instagram_handler,
            youtube_handler: form.youtube_handler,
            github_handler: form.github_handler
          )
        end

        def add_admins_as_followers(assembly)
          assembly.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: assembly.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: assembly.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

        def participatory_processes(assembly)
          @participatory_processes ||= assembly.participatory_space_sibling_scope(:participatory_processes).where(id: @form.participatory_processes_ids)
        end

        def link_participatory_processes(assembly)
          assembly.link_participatory_space_resources(participatory_processes(assembly), "included_participatory_processes")
        end
      end
    end
  end
end
