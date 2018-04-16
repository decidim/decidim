# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_consultation_action?
          allowed_question_action?
          allowed_response_action?

          permission_action
        end

        private

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
            allow!
          when :update, :destroy, :preview
            toggle_allow(consultation.present?)
          when :publish_results
            toggle_allow(consultation.finished? && !consultation.results_published?)
          when :unpublish_results
            toggle_allow(consultation.results_published?)
          end
        end

        def allowed_question_action?
          return unless permission_action.subject == :question

          case permission_action.action
          when :create, :read
            allow!
          when :update, :destroy, :preview
            toggle_allow(question.present?)
          when :publish
            toggle_allow(question.external_voting || question.responses_count.positive?)
          end
        end

        def allowed_response_action?
          return unless permission_action.subject == :response

          case permission_action.action
          when :create, :read
            allow!
          when :update, :destroy
            toggle_allow(response.present?)
          end
        end
      end
    end
  end
end
