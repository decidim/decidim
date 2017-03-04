# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process group in the system.
    class UpdateParticipatoryProcessGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # participatory_process_group - the ParticipatoryProcessGroup to update
      # form - A form object with the params.
      def initialize(participatory_process_group, form)
        @participatory_process_group = participatory_process_group
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
        update_participatory_process_group

        if @participatory_process_group.valid?
          broadcast(:ok, @participatory_process_group)
        else
          form.errors.add(:hero_image, @participatory_process_group.errors[:hero_image]) if @participatory_process_group.errors.include? :hero_image
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      def update_participatory_process_group
        @participatory_process_group.assign_attributes(attributes)
        @participatory_process_group.save! if @participatory_process_group.valid?
      end

      def attributes
        {
          name: form.name,
          hero_image: form.hero_image,
          description: form.description
        }
      end
    end
  end
end
