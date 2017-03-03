# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process group in the system.
    class CreateParticipatoryProcessGroup < Rectify::Command
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
        group = create_participatory_group

        if group.persisted?
          broadcast(:ok, group)
        else
          form.errors.add(:hero_image, group.errors[:hero_image]) if group.errors.include? :hero_image
          form.errors.add(:banner_image, group.errors[:banner_image]) if group.errors.include? :banner_image
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      def create_participatory_process_group
        transaction do
          group = ParticipatoryProcessGroup.create(
            name: form.title,
            description: form.description,
            hero_image: form.hero_image,
            organization: form.current_organization
          )

          group
        end
      end
    end
  end
end
