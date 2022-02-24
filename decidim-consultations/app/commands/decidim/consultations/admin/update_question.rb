# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating an existing participatory
      # question in the system.
      class UpdateQuestion < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        # Public: Initializes the command.
        #
        # question - the Question to update
        # form - A form object with the params.
        def initialize(question, form)
          @question = question
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

          update_question

          if question.valid?
            broadcast(:ok, question)
          else
            form.errors.add(:hero_image, question.errors[:hero_image]) if question.errors.include? :hero_image
            form.errors.add(:banner_image, question.errors[:banner_image]) if question.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :question

        def update_question
          question.assign_attributes(attributes)
          question.save! if question.valid?
        end

        def attributes
          {
            decidim_scope_id: form.decidim_scope_id,
            title: form.title,
            subtitle: form.subtitle,
            slug: form.slug,
            what_is_decided: form.what_is_decided,
            promoter_group: form.promoter_group,
            participatory_scope: form.participatory_scope,
            question_context: form.question_context,
            hashtag: form.hashtag,
            origin_scope: form.origin_scope,
            origin_title: form.origin_title,
            origin_url: form.origin_url,
            external_voting: form.external_voting,
            i_frame_url: form.i_frame_url,
            order: form.order
          }.merge(
            attachment_attributes(:hero_image, :banner_image)
          )
        end
      end
    end
  end
end
