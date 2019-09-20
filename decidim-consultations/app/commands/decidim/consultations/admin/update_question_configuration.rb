# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that configures how many and how much questions can be voted.
      class UpdateQuestionConfiguration < Rectify::Command
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
            max_votes: form.max_votes,
            min_votes: form.min_votes,
            instructions: form.instructions
          }
        end
      end
    end
  end
end
