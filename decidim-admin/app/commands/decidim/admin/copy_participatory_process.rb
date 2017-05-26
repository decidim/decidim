# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when copying a new participatory
    # process in the system.
    class CopyParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - A participatory_process we want to duplicate
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

        ParticipatoryProcess.transaction do
          copy_participatory_process
          copy_participatory_process_steps if @form.copy_steps?
          copy_participatory_process_categories if @form.copy_categories?
          copy_participatory_process_features if @form.copy_features?
        end

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
      end

      def copy_participatory_process_steps
        @steps_relationship = {}

        @participatory_process.steps.each do |step|
          new_step = ParticipatoryProcessStep.create!(
            title: step.title,
            description: step.description,
            start_date: step.start_date,
            end_date: step.end_date,
            participatory_process: @copied_process,
            position: step.position,
            active: step.active
          )
          @steps_relationship[step.id.to_s] = new_step.id.to_s
        end
      end

      def copy_participatory_process_categories
        @participatory_process.categories.each do |category|
          Category.create!(
            name: category.name,
            description: category.description,
            parent_id: category.parent_id,
            participatory_process: @copied_process
          )
        end
      end

      def copy_participatory_process_features
        @participatory_process.features.each do |feature|
          copied_step_settings = @form.copy_steps? ? map_step_settings(feature.step_settings) : {}
          new_feature = Feature.create!(
            manifest_name: feature.manifest_name,
            name: feature.name,
            participatory_process: @copied_process,
            settings: feature.settings,
            step_settings: copied_step_settings
          )
          feature.manifest.run_hooks(:copy, new_feature: new_feature, old_feature: feature)
        end
      end

      def map_step_settings(step_settings)
        step_settings.each_with_object({}) do |(step_id, settings), acc|
          acc.update(@steps_relationship[step_id.to_s] => settings)
        end
      end
    end
  end
end
