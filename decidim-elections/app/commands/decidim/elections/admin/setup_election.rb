# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is setup from the admin panel.
      class SetupElection < Rectify::Command
        # Public: Initializes the command.
        #
        # election - The election to setup.
        # bulletin_board - The BulletinBoard Client that includes the GraphLient Client
        def initialize(form, bulletin_board: Decidim::Elections.bulletin_board)
          @election = form.election
          @form = form
          @bulletin_board = bulletin_board
        end

        # Public: Setup the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            add_trustees_to_election
            setup_election
            log_action
            notify_trustee_about_election
          end

          if form.errors.any?
            broadcast(:invalid)
          else
            broadcast(:ok, election)
          end
        end

        private

        attr_reader :election, :form, :bulletin_board

        def questions
          @questions ||= election.questions
        end

        def answers
          Decidim::Elections::Answer.where(question: questions)
        end

        def trustees
          @trustees ||= Decidim::Elections::Trustee.where(id: form.trustee_ids)
        end

        def add_trustees_to_election
          return if election.trustees.exists?(id: form.trustee_ids)

          election.trustees << trustees
          election.save!
        end

        def election_id
          "#{bulletin_board.authority_slug}.#{election.id}"
        end

        def election_data
          {
            iat: Time.now.to_i,
            election_id: election_id,
            message_id: "#{election_id}.create_election+a.#{bulletin_board.authority_slug}",
            type: "create_election",
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
                  value: election.title[I18n.locale.to_s],
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
                          value: answer.title[I18n.locale.to_s],
                          language: I18n.locale.to_s
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
                    name: question.title[I18n.locale.to_s],
                    number_elected: question.answers.count,
                    votes_allowed: 1,
                    ballot_title: {
                      text: [{
                        value: question.title[I18n.locale.to_s],
                        language: I18n.locale.to_s
                      }]
                    },
                    ballot_subtitle: {
                      text: [{
                        value: question.description[I18n.locale.to_s],
                        language: I18n.locale.to_s
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
          response = bulletin_board.setup_election(election_data)

          if response.error.present?
            error = response.error
            form.errors.add(:base, error)
            raise ActiveRecord::Rollback
          else
            store_bulletin_board_status(response.election.status)
          end
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

        def store_bulletin_board_status(bb_status)
          @election.update!(
            blocked_at: Time.current,
            bb_status: bb_status
          )
        end
      end
    end
  end
end
