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
      end
    end
  end
end
