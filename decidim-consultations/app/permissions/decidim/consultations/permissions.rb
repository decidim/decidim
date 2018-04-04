# frozen_string_literal: true

module Decidim
  module Consultations
    class Permissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def allowed?
        return true if allowed_public_anonymous_action?

        return false unless user
        return true if allowed_public_action?

        return false unless permission_action.scope == :admin

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

      def allowed_public_anonymous_action?
        return unless permission_action.action == :read
        return unless permission_action.scope == :public

        case permission_action.subject
        when :consultation
          consultation.published? || user&.admin?
        when :question
          question.published? || user&.admin?
        else
          false
        end
      end

      def allowed_public_action?
        return unless permission_action.scope == :public
        return unless permission_action.subject == :question

        case permission_action.action
        when :vote
          question.can_be_voted_by?(user)
        when :unvote
          question.can_be_unvoted_by?(user)
        else
          false
        end
      end
    end
  end
end
