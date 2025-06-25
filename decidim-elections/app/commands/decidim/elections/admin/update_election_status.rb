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
            show_question(form.question_id)
          end
        end

        def start_election
          election.start_at = Time.current
        end

        def end_election
          election.end_at = Time.current
        end

        def show_question(question_id)
          # some code to show the question
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
