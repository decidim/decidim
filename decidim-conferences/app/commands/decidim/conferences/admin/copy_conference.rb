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
            slogan: @conference.slogan,
            slug: form.slug,
            hashtag: @conference.hashtag,
            description: @conference.description,
            short_description: @conference.short_description,
            location: @conference.location,
            hero_image: @conference.hero_image,
            banner_image: @conference.banner_image,
            promoted: @conference.promoted,
            scopes_enabled: @conference.scopes_enabled,
            scope: @conference.scope,
            objectives: @conference.objectives,
            start_date: @conference.start_date,
            end_date: @conference.end_date
          )
        end

        def copy_conference_categories
          @conference.categories.each do |category|
            category_copied = category.dup
            category_copied.participatory_space = @copied_conference
            category_copied.save
          end
        end

        def copy_conference_components
          @conference.components.each do |component|
            component_copied = component.dup
            component_copied.participatory_space = @copied_conference
            component_copied.save
            component.manifest.run_hooks(:copy, new_component: component_copied, old_component: component)
          end
        end
      end
    end
  end
end
