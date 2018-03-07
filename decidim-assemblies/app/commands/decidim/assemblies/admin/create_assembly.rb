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
            developer_group: form.developer_group,
            local_area: form.local_area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope
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
      end
    end
  end
end
