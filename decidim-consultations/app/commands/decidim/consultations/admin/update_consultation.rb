# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating an existing participatory
      # consultation in the system.
      class UpdateConsultation < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        # Public: Initializes the command.
        #
        # consultation - the Consultation to update
        # form - A form object with the params.
        def initialize(consultation, form)
          @consultation = consultation
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

          update_consultation

          if consultation.valid?
            broadcast(:ok, consultation)
          else
            form.errors.add(:banner_image, consultation.errors[:banner_image]) if consultation.errors.include? :banner_image
            form.errors.add(:introductory_image, consultation.errors[:introductory_image]) if consultation.errors.include? :introductory_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :consultation

        def update_consultation
          consultation.assign_attributes(attributes)
          consultation.save! if consultation.valid?
        end

        def attributes
          {
            title: form.title,
            subtitle: form.subtitle,
            description: form.description,
            slug: form.slug,
            highlighted_scope: form.highlighted_scope,
            introductory_video_url: form.introductory_video_url,
            start_voting_date: form.start_voting_date,
            end_voting_date: form.end_voting_date
          }.merge(
            attachment_attributes(:introductory_image, :banner_image)
          )
        end
      end
    end
  end
end
