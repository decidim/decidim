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
          assembly = create_assembly

          if assembly.persisted?
            broadcast(:ok, assembly)
          else
            form.errors.add(:hero_image, assembly.errors[:hero_image]) if assembly.errors.include? :hero_image
            form.errors.add(:banner_image, assembly.errors[:banner_image]) if assembly.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_assembly
          assembly = Assembly.new(
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
            scope: form.scope,
            developer_group: form.developer_group,
            local_area: form.local_area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope
          )

          return assembly unless assembly.valid?
          assembly.save!
          assembly
        end
      end
    end
  end
end
