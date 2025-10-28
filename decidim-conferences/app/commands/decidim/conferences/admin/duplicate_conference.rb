# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when duplicating a new participatory
      # conference in the system.
      class DuplicateConference < Decidim::Command
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
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Conference.transaction do
            duplicate_conference
            duplicate_conference_attachments
            duplicate_conference_components if @form.duplicate_components?
          end

          broadcast(:ok, @duplicated_conference)
        end

        private

        attr_reader :form

        def duplicate_conference
          @duplicated_conference = Conference.create!(
            organization: @conference.organization,
            title: form.title,
            slogan: @conference.slogan,
            slug: form.slug,
            description: @conference.description,
            short_description: @conference.short_description,
            location: @conference.location,
            promoted: @conference.promoted,
            objectives: @conference.objectives,
            start_date: @conference.start_date,
            end_date: @conference.end_date,
            taxonomies: @conference.taxonomies
          )
        end

        def duplicate_conference_attachments
          [:hero_image, :banner_image].each do |attribute|
            next unless @conference.attached_uploader(attribute).attached?

            @duplicated_conference.send(attribute).attach(@conference.send(attribute).blob)
          end
        end

        def duplicate_conference_components
          @conference.components.each do |component|
            component_duplicated = component.dup
            component_duplicated.participatory_space = @duplicated_conference
            component_duplicated.save
            component.manifest.run_hooks(:duplicate, new_component: component_duplicated, old_component: component)
          end
        end
      end
    end
  end
end
