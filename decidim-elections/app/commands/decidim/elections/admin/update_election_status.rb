# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElectionStatus < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        def call
          return broadcast(:invalid) unless form.valid?

          transaction do
            update_status
            election.save!
          end

          broadcast(:ok, election)
        rescue StandardError => e
          Rails.logger.error "#{e.class.name}: #{e.message}"
          broadcast(:invalid)
        end

        private

        attr_reader :form, :election

        def update_status
          case form.status_action
          when :start
            start_election
          when :end
            end_election
          when :publish_results
            publish_results
          when :show_question
            mark_question_as_open(form.question_id)
          end
        end

        def mark_question_as_open(question_id)
          current_ids = fetch_open_questions
          current_ids << question_id.to_i unless current_ids.include?(question_id.to_i)
          save_open_questions(current_ids)
        end

        def fetch_open_questions
          Decidim::Settings.for(:elections).fetch(shown_questions_key) { [] }.map(&:to_i)
        end

        def save_open_questions(ids)
          Decidim::Settings.for(:elections).store(shown_questions_key, ids.uniq)
        end

        def shown_questions_key
          "election_#{election.id}_open_questions"
        end

        def start_election
          election.start_at = Time.current
        end

        def end_election
          election.end_at = Time.current
        end

        def publish_results
          election.per_question? ? publish_results_per_question : publish_all_results
        end

        def publish_results_per_question
          question = election.questions.detect { |q| q.published_results_at.nil? && election.results_publishable_for?(q) }

          raise "No publishable question found" unless question

          question.update!(published_results_at: Time.current)
        end

        def publish_all_results
          return if election.results_published?

          election.published_results_at = Time.current
        end
      end
    end
  end
end
