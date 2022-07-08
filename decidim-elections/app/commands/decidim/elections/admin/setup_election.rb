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
          @election_data ||= begin
            ret = base_election_data
            election.participatory_space.try(:complete_election_data, election, ret)
            ret
          end
        end

        def base_election_data
          {
            trustees: trustees_data,
            default_locale: current_organization.default_locale,
            title: flatten_translations(election.title),
            start_date: election.start_time,
            end_date: election.end_time,
            questions: questions_data,
            answers: answers_data,
            ballot_styles: {}
          }
        end

        def trustees_data
          trustees.map do |trustee|
            {
              name: trustee.name,
              slug: trustee.bulletin_board_slug,
              public_key: JSON.parse(trustee.public_key)
            }
          end
        end

        def questions_data
          questions.map do |question|
            {
              slug: question.slug,
              weight: question.weight,
              max_selections: question.max_selections,
              title: flatten_translations(question.title),
              # the bulletin_board gem (ruby client) expects a description for the question
              # as development is in a separate repository, let's send an empty content for the moment
              description: {},
              answers: question_answers_data(question)
            }
          end
        end

        def question_answers_data(question)
          question.answers.map do |answer|
            {
              slug: answer.slug,
              weight: answer.weight
            }
          end
        end

        def answers_data
          answers.map do |answer|
            {
              slug: answer.slug,
              title: flatten_translations(answer.title)
            }
          end
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

          Decidim::EventsManager.publish(**data)
        end

        # Since machine_translations return a nested hash but Electionguard and other
        # schemes expect the translations to be returned in a "simple" hash, we need to
        # flatten the translations.
        #   {
        #     "language": "en",
        #      "value": "Jubilee Alliance"
        #   }
        # You can read more about the Civics Common Standard Data Specification here:
        # https://developers.google.com/civics-data/reference/internationalized-text
        def flatten_translations(translated_attribute)
          translated_attribute.deep_symbolize_keys!
          machine_translations = translated_attribute.delete(:machine_translations) || {}

          machine_translations.merge(translated_attribute).reject { |_k, v| v.empty? }
        end
      end
    end
  end
end
