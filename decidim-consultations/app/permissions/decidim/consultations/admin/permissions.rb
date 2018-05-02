# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin
          return permission_action if consultation && !consultation.is_a?(Decidim::Consultation)

          unless user.admin?
            disallow!
            return permission_action
          end

          user_can_enter_space_area?

          if read_admin_dashboard_action?
            allow!
            return permission_action
          end

          allowed_read_participatory_space?
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
          @consultation ||= context.fetch(:consultation, nil) || context.fetch(:participatory_space, nil)
        end

        def response
          @response ||= context.fetch(:response, nil)
        end

        def allowed_consultation_action?
          return unless permission_action.subject == :consultation

          case permission_action.action
          when :create, :read, :publish
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

        # Only admin users can enter the consultations area.
        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :consultations

          allow!
        end

        def read_admin_dashboard_action?
          permission_action.action == :read &&
            permission_action.subject == :admin_dashboard
        end

        def allowed_read_participatory_space?
          return unless permission_action.action == :read &&
                        permission_action.subject == :participatory_space

          allow!
        end
      end
    end
  end
end
