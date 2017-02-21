# frozen_string_literal: true
module Decidim
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
        process = create_participatory_process

        if process.persisted?
          broadcast(:ok, process)
        else
          form.errors.add(:hero_image, process.errors[:hero_image]) if process.errors.include? :hero_image
          form.errors.add(:banner_image, process.errors[:banner_image]) if process.errors.include? :banner_image
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      def create_participatory_process
        transaction do
          process = ParticipatoryProcess.new(
            title: form.title,
            subtitle: form.subtitle,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            scope_ids: form.scopes.map(&:id),
            organization: form.current_organization
          )

          return process unless process.valid?
          process.save!

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
    end
  end
end
