# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user creates a Question
      # from the admin panel.
      class CreateQuestion < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the question if valid.
        #
        # Broadcasts :ok if successful, :ongoing_election if the
        # election already started, and :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?
          return broadcast(:election_ongoing) if election_started?

          create_question!

          broadcast(:ok, question)
        end

        private

        attr_reader :form, :question

        def invalid?
          form.invalid?
        end

        def election_started?
          form.election.started?
        end

        def create_question!
          attributes = {
            election: form.election,
            title: form.title,
            description: form.description,
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
