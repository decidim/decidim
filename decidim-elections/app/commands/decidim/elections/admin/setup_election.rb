# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is setup from the admin panel.
      class SetupElection < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A SetupForm object with the information needed to setup the election
        def initialize(form)
          @form = form
        end

        # Public: Setup the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            update_election
            notify_trustee_about_election
            setup_election
          end

          broadcast(:ok, election)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        delegate :election, :bulletin_board, :current_organization, to: :form

        def questions
          @questions ||= election.questions
        end

        def answers
          Decidim::Elections::Answer.where(question: questions)
        end

        def trustees
          @trustees ||= Decidim::Elections::Trustee.where(id: form.trustee_ids).order(:id)
        end

        def update_election
          return if election.trustees.exists?(id: form.trustee_ids)

          election.trustees << trustees
          election.blocked_at = Time.current
          election.bb_created!
        end

        def election_data
          {
            iat: Time.current.to_i,
            scheme: bulletin_board.scheme,
            authority: {
              name: bulletin_board.authority_name,
              public_key: bulletin_board.public_key
            },
            trustees:
              trustees.collect do |trustee|
                {
                  name: trustee.name,
                  public_key: trustee.public_key
                }
              end,
            description: {
              name: {
                text: [{
                  value: election.title[current_organization.default_locale.to_s],
                  language: current_organization.default_locale.to_s
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
                          value: answer.title[current_organization.default_locale.to_s],
                          language: current_organization.default_locale.to_s
                        }]
                      }
                    }
                  end,
              contests:
                questions.collect do |question|
                  {
                    "@type": "CandidateContest",
                    object_id: question.id.to_s,
                    sequence_order: question.weight,
                    vote_variation: question.vote_variation,
                    name: question.title[current_organization.default_locale.to_s],
                    number_elected: question.answers.count,
                    votes_allowed: 1,
                    ballot_title: {
                      text: [{
                        value: question.title[current_organization.default_locale.to_s],
                        language: current_organization.default_locale.to_s
                      }]
                    },
                    ballot_subtitle: {
                      text: [{
                        value: question.description[current_organization.default_locale.to_s],
                        language: current_organization.default_locale.to_s
                      }]
                    },
                    ballot_selections:
                      question.answers.collect do |answer|
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

        def setup_election
          bb_election = bulletin_board.create_election(election.id, election_data)

          raise StandardError, "Wrong status for the created election" if bb_election.status != "created"
        end

        def log_action
          Decidim.traceability.perform_action!(
            :setup,
            election,
            form.current_user,
            visibility: "all"
          )
        end

        def notify_trustee_about_election
          trustee = trustees.collect(&:user)
          data = {
            event: "decidim.events.elections.trustees.new_election",
            event_class: Decidim::Elections::Trustees::NotifyTrusteeNewElectionEvent,
            resource: election,
            affected_users: trustee
          }

          Decidim::EventsManager.publish(data)
        end
      end
    end
  end
end
