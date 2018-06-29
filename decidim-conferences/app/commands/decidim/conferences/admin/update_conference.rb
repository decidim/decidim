# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new participatory
      # conference in the system.
      class UpdateConference < Rectify::Command
        # Public: Initializes the command.
        #
        # conference - the Conference to update
        # form - A form object with the params.
        def initialize(conference, form)
          @conference = conference
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
          update_conference
          link_participatory_processes(@conference)

          if @conference.valid?
            broadcast(:ok, @conference)
          else
            form.errors.add(:hero_image, @conference.errors[:hero_image]) if @conference.errors.include? :hero_image
            form.errors.add(:banner_image, @conference.errors[:banner_image]) if @conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference

        def update_conference
          @conference.assign_attributes(attributes)
          save_conference if @conference.valid?
        end

        def save_conference
          transaction do
            @conference.save!
            Decidim.traceability.perform_action!(:update, @conference, form.current_user) do
              @conference
            end
          end
        end

        def attributes
          {
            title: form.title,
            slogan: form.subtitle,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            show_statistics: form.show_statistics,
          }
        end
      end
    end
  end
end
