# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating an existing participatory
      # question in the system.
      class UpdateQuestion < Rectify::Command
        # Public: Initializes the command.
        #
        # question - the Question to update
        # form - A form object with the params.
        def initialize(question, form)
          form.hero_image = question.hero_image if form.hero_image.blank?
          form.banner_image = question.banner_image if form.banner_image.blank?

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
          }.merge(uploader_attributes)
        end

        def uploader_attributes
          {
            hero_image: form.hero_image,
            remove_hero_image: form.remove_hero_image,
            banner_image: form.banner_image,
            remove_banner_image: form.remove_banner_image
          }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
        end
      end
    end
  end
end
