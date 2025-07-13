# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateQuestions < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        def call
          return broadcast(:invalid) if @form.invalid?

          @form.questions.each do |question_form|
            if question_form.deleted?
              delete_question(question_form)
            else
              update_question(question_form)
            end
          end

          broadcast(:ok)
        end

        private

        def delete_question(question_form)
          question = @election.questions.find_by(id: question_form.id)
          return unless question

          Decidim.traceability.perform_action!(
            "delete",
            question,
            @form.current_user,
            election: @election
          ) do
            question.destroy!
          end
        end

        def update_question(question_form)
          question = find_or_build_question(question_form)

          question.assign_attributes(
            body: question_form.body,
            description: question_form.description,
            question_type: question_form.question_type,
            position: question_form.position.to_i,
            mandatory: question_form.mandatory
          )

          Decidim.traceability.perform_action!(
            "update",
            question,
            @form.current_user,
            election: @election
          ) do
            question.save!
            update_response_options(question, question_form.response_options)
          end
        end

        def find_or_build_question(question_form)
          @election.questions.find_by(id: question_form.id) || @election.questions.build
        end

        def update_response_options(question, option_forms)
          option_forms.each do |option_form|
            if option_form.deleted?
              delete_response_option(question, option_form)
            else
              save_response_option(question, option_form)
            end
          end
        end

        def delete_response_option(question, option_form)
          option = question.response_options.find_by(id: option_form.id)
          option&.destroy!
        end

        def save_response_option(question, option_form)
          option = question.response_options.find_by(id: option_form.id) || question.response_options.build
          option.body = option_form.body
          option.save!
        end
      end
    end
  end
end
