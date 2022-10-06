# frozen_string_literal: true

module Decidim
  module Consultations
    # This module, when injected into a controller, ensures there's a
    # question available and deducts it from the context.
    module NeedsQuestion
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_question, :previous_question, :next_question, :previous_published_question, :next_published_question,
                        :current_consultation, :current_participatory_space, :stats, :sorted_results

          helper Decidim::WidgetUrlsHelper
        end
      end

      def self.extended(base)
        base.extend Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      def self.included(base)
        base.include Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      module InstanceMethods
        # Public: Finds the current Question given this controller's
        # context.
        #
        # Returns the current Question.
        def current_question
          @current_question ||= detect_question
        end

        # Public: Finds the previous Question in the Array of questions
        # associated to the current_question's consultation.
        #
        # Returns the previous Question in the Array or nil if out of bounds.
        def previous_question
          return nil if (current_question_index - 1).negative?

          current_consultation_questions.at(current_question_index - 1)
        end

        # Public: Finds the next Question in the Array of questions
        # associated to the current_question's consultation.
        #
        # Returns the next Question in the Array or nil if out of bounds.
        def next_question
          return nil if current_question_index + 1 >= current_consultation_questions.size

          current_consultation_questions.at(current_question_index + 1)
        end

        # same as next_question but for published questions only
        def next_published_question
          return nil if current_published_question_index + 1 >= current_consultation_published_questions.size

          current_consultation_published_questions.at(current_published_question_index + 1)
        end

        # same as previous_question but for published questions only
        def previous_published_question
          return nil if (current_published_question_index - 1).negative?

          current_consultation_published_questions.at(current_published_question_index - 1)
        end

        # Public: Finds the current Consultation given this controller's
        # context.
        #
        # Returns the current Consultation.
        def current_consultation
          @current_consultation ||= current_question&.consultation || detect_consultation
        end

        alias current_participatory_space current_question

        private

        def detect_question
          return unless request.env["current_question"] || params[:question_slug] || params[:slug]

          request.env["current_question"] ||
            OrganizationQuestions.for(current_organization).find_by!(slug: params[:question_slug] || params[:slug])
        end

        def detect_consultation
          request.env["current_consultation"] ||
            organization_consultations.find_by(slug: params[:consultation_slug])
        end

        def organization_consultations
          @organization_consultations ||= OrganizationConsultations.new(current_organization).query
        end

        def stats
          @stats ||= QuestionStatsPresenter.new(question: current_question)
        end

        def current_consultation_questions
          @current_consultation_questions ||= current_question.consultation.questions.to_a
        end

        def current_consultation_published_questions
          @current_consultation_published_questions ||= current_question.consultation.questions.published.to_a
        end

        def current_question_index
          current_consultation_questions.find_index(current_question)
        end

        def current_published_question_index
          current_consultation_published_questions.find_index(current_question) || -1
        end
      end
    end
  end
end
