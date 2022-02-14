# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when creating a new participatory
      # consultation in the system.
      class CreateConsultation < Decidim::Command
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

          consultation = create_consultation

          if consultation.persisted?
            broadcast(:ok, consultation)
          else
            form.errors.add(:banner_image, consultation.errors[:banner_image]) if consultation.errors.include? :banner_image
            form.errors.add(:introductory_image, consultation.errors[:introductory_image]) if consultation.errors.include? :introductory_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_consultation
          consultation = Consultation.new(
            organization: form.current_organization,
            title: form.title,
            subtitle: form.subtitle,
            description: form.description,
            slug: form.slug,
            banner_image: form.banner_image,
            highlighted_scope: form.highlighted_scope,
            introductory_video_url: form.introductory_video_url,
            start_voting_date: form.start_voting_date,
            end_voting_date: form.end_voting_date,
            introductory_image: form.introductory_image
          )

          return consultation unless consultation.valid?

          consultation.save
          consultation
        end
      end
    end
  end
end
