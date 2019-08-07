# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when creating a new question
      class CreateQuestion < Rectify::Command
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

          question = create_question

          if question.persisted?
            broadcast(:ok, question)
          else
            form.errors.add(:hero_image, question.errors[:hero_image]) if question.errors.include? :hero_image
            form.errors.add(:banner_image, question.errors[:banner_image]) if question.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_question
          question = Question.new(
            consultation: form.context.current_consultation,
            organization: form.context.current_consultation.organization,
            decidim_scope_id: form.decidim_scope_id,
            title: form.title,
            slug: form.slug,
            subtitle: form.subtitle,
            what_is_decided: form.what_is_decided,
            promoter_group: form.promoter_group,
            participatory_scope: form.participatory_scope,
            question_context: form.question_context,
            hashtag: form.hashtag,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            origin_scope: form.origin_scope,
            origin_title: form.origin_title,
            origin_url: form.origin_url,
            external_voting: form.external_voting,
            i_frame_url: form.i_frame_url,
            order: form.order
          )

          return question unless question.valid?

          question.save
          question
        end
      end
    end
  end
end
