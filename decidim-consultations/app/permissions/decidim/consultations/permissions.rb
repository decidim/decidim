# frozen_string_literal: true

module Decidim
  module Consultations
    class Permissions < Decidim::DefaultPermissions
      def permissions
        allowed_public_anonymous_action?

        permission_action unless user
        allowed_public_action?

        permission_action unless permission_action.scope == :admin
        return Decidim::Consultations::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end

      private

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
        when :consultation_list
          allow!
        when :consultation
          toggle_allow(consultation.published? || user&.admin?)
        when :question
          toggle_allow(question.published? || user&.admin?)
        end
      end

      def allowed_public_action?
        return unless permission_action.scope == :public
        return unless permission_action.subject == :question

        case permission_action.action
        when :vote
          toggle_allow(question.can_be_voted_by?(user))
        when :unvote
          toggle_allow(question.can_be_unvoted_by?(user))
        end
      end
    end
  end
end
