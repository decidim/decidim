# frozen_string_literal: true

module Decidim
  module Api
    class ApiUser < UserBaseEntity
      include Decidim::Traceable

      attribute :tos_agreement, :boolean, default: true

      devise :api_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

      validates :api_key, :name, uniqueness: { case_sensitive: true, scope: :organization }

      def presenter
        Decidim::Api::ApiUserPresenter.new(self)
      end

      def self.log_presenter_class_for(_log)
        Decidim::AdminLog::UserPresenter
      end

      # Checks if the user has the given `role` or not.
      #
      # role - a String or a Symbol that represents the role that is being
      #   checked
      #
      # Returns a boolean.
      def role?(role)
        roles.include?(role.to_s)
      end

      # Public: Returns the active role of the user
      def active_role
        admin ? "admin" : roles.first
      end

      # Public: returns the user's name or the default one
      def name
        super || I18n.t("decidim.anonymous_user")
      end

      # Check if the user account has been deleted or not
      def deleted?
        deleted_at.present?
      end

      # Public: whether the user has been officialized or not
      def officialized?
        !officialized_at.nil?
      end

      def confirmed?
        true
      end

      def follows?(followable)
        Decidim::Follow.where(user: self, followable: followable).any?
      end

      # Public: whether the user accepts direct messages from another
      def accepts_conversation?(_user)
        false
      end

      def unread_conversations
        Decidim::Messaging::Conversation.unread_by(self)
      end

      def tos_accepted?
        true
      end

      def admin_terms_accepted?
        true
      end

      def needs_password_update?
        false
      end
    end
  end
end
