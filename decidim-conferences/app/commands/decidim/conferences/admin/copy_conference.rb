# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when copying a new participatory
      # conference in the system.
      class CopyConference < Decidim::Command
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
            copy_conference
            copy_conference_attachments
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

        def copy_conference_attachments
          [:hero_image, :banner_image].each do |attribute|
            next unless @conference.attached_uploader(attribute).attached?

            @copied_conference.send(attribute).attach(@conference.send(attribute).blob)
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
