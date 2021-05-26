# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating an existing participatory
      # consultation in the system.
      class UpdateConsultation < Rectify::Command
        # Public: Initializes the command.
        #
        # consultation - the Consultation to update
        # form - A form object with the params.
        def initialize(consultation, form)
          form.banner_image = consultation.banner_image if form.banner_image.blank?
          form.introductory_image = consultation.introductory_image if form.introductory_image.blank?

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
          }.merge(uploader_attributes)
        end

        def uploader_attributes
          {
            banner_image: form.banner_image,
            remove_banner_image: form.remove_banner_image,
            introductory_image: form.introductory_image,
            remove_introductory_image: form.remove_introductory_image
          }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
        end
      end
    end
  end
end
