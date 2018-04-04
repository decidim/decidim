# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class Permissions
        def initialize(user, permission_action, context = {})
          @user = user
          @permission_action = permission_action
          @context = context
        end

        def allowed?
          return false unless user
          return false unless permission_action.scope == :admin

          return true if allowed_consultation_action?
          return true if allowed_question_action?
          return true if allowed_response_action?

          false
        end

        private

        attr_reader :user, :context, :permission_action

        def question
          @question ||= context.fetch(:question, nil)
        end

        def consultation
          @consultation ||= context.fetch(:consultation, nil)
        end

        def response
          @response ||= context.fetch(:response, nil)
        end

        def allowed_consultation_action?
          return unless permission_action.subject == :consultation

          case permission_action.action
          when :create, :read
            true
          when :update, :destroy, :preview
            consultation.present?
          when :publish_results
            consultation.finished? && !consultation.results_published?
          when :unpublish_results
            consultation.results_published?
          else
            false
          end
        end

        def allowed_question_action?
          return unless permission_action.subject == :question

          case permission_action.action
          when :create, :read
            true
          when :update, :destroy, :preview
            question.present?
          when :publish
            question.external_voting || question.responses_count.positive?
          else
            false
          end
        end

        def allowed_response_action?
          return unless permission_action.subject == :response

          case permission_action.action
          when :create, :read
            true
          when :update, :destroy
            response.present?
          end
        end
      end
    end
  end
end
