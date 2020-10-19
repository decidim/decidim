# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is setup from the admin panel.
      class SetupElection < Rectify::Command
        # Public: Initializes the command.
        #
        # election - The election to setup.
        # current_user - the user performing the action
        def initialize(form)
          @election = form.election
          @trustees = form.trustees
          @form = form
        end

        # Public: Setup the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            add_trustees_to_election!
            setup_election
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :trustees, :form

        def questions
          @questions = election.questions
        end

        def answers
          Decidim::Elections::Answer.where(question: questions)
        end

        def add_trustees_to_election!
          election.trustees << trustees
          election.save!
        end

        def election_data
          {
            iat: Time.now.to_i,
            scheme: Decidim::Elections.bulletin_board.scheme,
            trustees:
              trustees.collect do |trustee|
                {
                  name: trustee.user.name,
                  public_key: Random.urlsafe_base64(30)
                }
              end,
            description: {
              name: {
                text: [{
                  value: election.title["en"],
                  language: I18n.locale.to_s
                }]
              },
              start_date: election.start_time,
              end_date: election.end_time,
              candidates:
                  answers.collect do |answer|
                    {
                      object_id: answer.id.to_s,
                      ballot_name: {
                        text: [{
                          value: answer.title["en"],
                          language: I18n.locale.to_s
                        }]
                      }
                    }
                  end,
              contests:
                questions.collect do |question|
                  {
                    "@type": "QuestionType",
                    object_id: question.id.to_s,
                    sequence_order: question.weight,
                    vote_variation: question.vote_variation,
                    name: question.title["en"],
                    number_elected: question.answers.count,
                    votes_allowed: 1,
                    ballot_title: {
                      text: [{
                        value: question.title["en"],
                        language: I18n.locale.to_s
                      }]
                    },
                    ballot_subtitle: {
                      text: [{
                        value: question.description["en"],
                        language: I18n.locale.to_s
                      }]
                    },
                    ballot_selections:
                      answers.collect do |answer|
                        {
                          object_id: answer.id.to_s,
                          sequence_order: answer.weight,
                          candidate_id: answer.id.to_s
                        }
                      end
                  }
                end
            }
          }.to_h
        end

        def setup_election!
          signed_data = Decidim::Elections.bulletin_board.encode_data(election_data)
          api_key = Decidim::Elections.bulletin_board.instance_variable_get "@api_key"

          Decidim::Elections.bulletin_board.graphql_client.query do
            mutation do
              createElection(signedData: signed_data, apiKey: api_key) do
                election
              end
            end
          end
        end

        def setup_election
          Decidim.traceability.perform_action!(
            :setup,
            election,
            form.current_user,
            visibility: "all"
          ) do
            setup_election!
          end
        end
      end
    end
  end
end
