# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to udpate the ballot style
      class UpdateBallotStyle < Rectify::Command
        def initialize(form, ballot_style)
          @form = form
          @ballot_style = ballot_style
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          transaction do
            udpate_ballot_style!
            destroy_removed_ballot_style_questions!
            create_added_ballot_style_questions!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :ballot_style

        def udpate_ballot_style!
          attributes = {
            code: form.code,
            title: form.title
          }

          ballot_style.update!(attributes)
        end

        def destroy_removed_ballot_style_questions!
          (ballot_style.question_ids - form.question_ids).each do |question_id|
            Decidim::Votings::BallotStyleQuestion
              .where(
                decidim_votings_ballot_style_id: ballot_style.id,
                decidim_elections_question_id: question_id
              )
              .delete_all
          end
        end

        def create_added_ballot_style_questions!
          (form.question_ids - ballot_style.question_ids).each do |question_id|
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
