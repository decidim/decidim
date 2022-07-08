# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user creates a Question
      # from the admin panel.
      class CreateQuestion < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the question if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:election_started) if form.election.started?
          return broadcast(:invalid) if form.invalid?

          create_question!

          broadcast(:ok, question)
        end

        private

        attr_reader :form, :question

        def create_question!
          attributes = {
            election: form.election,
            title: form.title,
            max_selections: form.max_selections,
            weight: form.weight,
            random_answers_order: form.random_answers_order,
            min_selections: form.min_selections
          }

          @question = Decidim.traceability.create!(
            Question,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
