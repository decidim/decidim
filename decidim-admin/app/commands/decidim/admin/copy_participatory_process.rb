# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when copying a new participatory
    # process in the system.
    class CopyParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        copy_participatory_process

        broadcast(:ok, @copied_process)
      end

      private

      attr_reader :form

      def copy_participatory_process
        @copied_process = ParticipatoryProcess.create!(
          organization: @participatory_process.organization,
          title: form.title,
          subtitle: @participatory_process.subtitle,
          slug: form.slug,
          hashtag: @participatory_process.hashtag,
          description: @participatory_process.description,
          short_description: @participatory_process.short_description,
          hero_image: @participatory_process.hero_image,
          banner_image: @participatory_process.banner_image,
          promoted: @participatory_process.promoted,
          scope: @participatory_process.scope,
          developer_group: @participatory_process.developer_group,
          local_area: @participatory_process.local_area,
          target: @participatory_process.target,
          participatory_scope: @participatory_process.participatory_scope,
          participatory_structure: @participatory_process.participatory_structure,
          meta_scope: @participatory_process.meta_scope,
          end_date: @participatory_process.end_date,
          participatory_process_group: @participatory_process.participatory_process_group
        )

        # return process unless process.valid?
        # transaction do
        #   process.save!

        #   process.steps.create!(
        #     title: TranslationsHelper.multi_translation(
        #       "decidim.admin.participatory_process_steps.default_title",
        #       form.current_organization.available_locales
        #     ),
        #     active: true
        #   )

        #   process
        # end
      end
    end
  end
end
