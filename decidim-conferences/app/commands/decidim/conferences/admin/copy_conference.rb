# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when copying a new participatory
      # conference in the system.
      class CopyConference < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference - An conference we want to duplicate
        def initialize(form, conference)
          @form = form
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Conference.transaction do
            copy_conference
            copy_conference_categories if @form.copy_categories?
            copy_conference_components if @form.copy_components?
          end

          broadcast(:ok, @copied_conference)
        end

        private

        attr_reader :form

        def copy_conference
          @copied_conference = Conference.create!(
            organization: @conference.organization,
            title: form.title,
            slogan: @conference.subtitle,
            slug: form.slug,
            hashtag: @conference.hashtag,
            description: @conference.description,
            short_description: @conference.short_description,
            hero_image: @conference.hero_image,
            banner_image: @conference.banner_image,
            promoted: @conference.promoted,
            scope: @conference.scope,
            objectives: @conference.objectives,
            start_date: @conference.start_date,
            end_date: @conference.end_date
            )
        end

        def copy_conference_categories
          @conference.categories.each do |category|
            Category.create!(
              name: category.name,
              description: category.description,
              parent_id: category.parent_id,
              participatory_space: @copied_conference
            )
          end
        end

        def copy_conference_components
          @conference.components.each do |component|
            new_component = Component.create!(
              manifest_name: component.manifest_name,
              name: component.name,
              participatory_space: @copied_conference,
              settings: component.settings,
              step_settings: component.step_settings
            )
            component.manifest.run_hooks(:copy, new_component: new_component, old_component: component)
          end
        end
      end
    end
  end
end
