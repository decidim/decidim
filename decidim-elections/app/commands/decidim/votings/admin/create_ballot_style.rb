# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to create the ballot style
      class CreateBallotStyle < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          begin
            create_ballot_style!
          rescue ActiveRecord::RecordNotUnique
            form.errors.add(:code, :taken)
            return broadcast(:invalid)
          end

          create_ballot_style_questions!

          broadcast(:ok)
        end

        private

        attr_reader :form, :ballot_style

        def create_ballot_style!
          params = {
            code: form.code,
            voting: form.current_participatory_space
          }

          @ballot_style = Decidim.traceability.create!(
            Decidim::Votings::BallotStyle,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def create_ballot_style_questions!
          form.question_ids.each do |question_id|
            Decidim::Votings::BallotStyleQuestion.create!(
              decidim_votings_ballot_style_id: ballot_style.id,
              decidim_elections_question_id: question_id
            )
          end
        end
      end
    end
  end
end
