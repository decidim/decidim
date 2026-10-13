# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user responds a Questionnaire.
    class ResponseQuestionnaire < Decidim::Command
      delegate :current_user, to: :form
      include ::Decidim::MultipleAttachmentsMethods

      # Initializes a ResponseQuestionnaire Command.
      #
      # form - The form from which to get the data.
      # questionnaire - The current instance of the questionnaire to be responded.
      # allow_editing_responses - Flag that ensures a form can or cannot be editable after the questionnaire's responses have been provided.
      def initialize(form, questionnaire, allow_editing_responses: false)
        @form = form
        @questionnaire = questionnaire
        @allow_editing_responses = allow_editing_responses
      end

      # Responds a questionnaire if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid? || (user_already_responded? && !allow_editing_responses)

        with_events { response_questionnaire }

        if @errors
          reset_form_attachments
          broadcast(:invalid)
        else
          broadcast(:ok)
        end
      end

      attr_reader :form, :questionnaire, :allow_editing_responses

      private

      def event_arguments
        {
          resource: questionnaire,
          extra: {
            session_token: @submission&.session_token || form.context.session_token,
            questionnaire:,
            event_author: current_user
          }
        }
      end

      # This method will add an error to the `add_documents` field only if there is
      # any error in any other field or an error in another response in the
      # questionnaire. This is needed because when the form has
      # an error, the attachments are lost, so we need a way to inform the user
      # of this problem.
      def reset_form_attachments
        @form.responses.each do |response|
          response.errors.add(:add_attachments, :needs_to_be_reattached) if response.has_attachments? || response.has_error_in_attachments?
        end
      end

      def build_choices(response, form_response)
        use_position = form_response.sorting?

        form_response.selected_choices.each_with_index do |choice, idx|
          choice_position = use_position ? choice.position.presence || idx : choice.position
          response.choices.build(
            body: choice.body,
            custom_body: choice.custom_body,
            decidim_response_option_id: choice.response_option_id,
            decidim_question_matrix_row_id: choice.matrix_row_id,
            position: choice_position
          )
        end
      end

      def submission
        @submission ||= questionnaire.submission_for(user: current_user, session_token: form.context.session_token) ||
                        questionnaire.submissions
                                     .create_with(user: current_user, ip_hash: form.context.ip_hash)
                                     .create_or_find_by!(session_token: form.context.session_token)
      end

      def response_questionnaire
        @main_form = @form
        @errors = nil

        submission.with_lock(requires_new: true) do
          saved_response_ids = []

          form.responses_by_step.flatten.select(&:display_conditions_fulfilled?).each do |form_response|
            response = save_response(form_response)
            saved_response_ids << response.id

            next unless form_response.question.has_attachments?

            # The attachments module expects `@form` to be the form with the
            # attachments
            @form = form_response
            @attached_to = response

            build_attachments

            if attachments_invalid?
              @errors = true
              next
            end

            create_attachments if process_attachments?
            attachment_cleanup!
          end

          submission.responses.where.not(id: saved_response_ids).destroy_all
          submission.update!(ip_hash: form.context.ip_hash, updated_at: Time.current)
          @form = @main_form
          raise ActiveRecord::Rollback if @errors
        end
      end

      def save_response(form_response)
        response = submission.responses.order(:id).find_or_initialize_by(question: form_response.question)
        response.assign_attributes(
          user: current_user,
          questionnaire:,
          body: form_response.body,
          session_token: submission.session_token,
          ip_hash: form.context.ip_hash
        )
        response.choices.destroy_all if response.persisted?
        build_choices(response, form_response)
        response.save!
        response
      end

      def user_already_responded?
        questionnaire.responded_by?(current_user || form.context.session_token)
      end
    end
  end
end
