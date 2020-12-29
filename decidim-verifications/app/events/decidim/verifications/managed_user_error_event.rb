# frozen-string_literal: true

module Decidim
  module Verifications
    class ManagedUserErrorEvent < Decidim::Events::SimpleEvent
      delegate :profile_path, :profile_url, :name, to: :updated_user

      def i18n_scope
        "decidim.events.verifications.verify_with_managed_user"
      end

      def resource_path
        profile_path
      end

      def resource_url
        profile_url
      end

      def resource_title
        updated_user.name
      end

      def default_i18n_options
        super.merge({ managed_user_path: managed_user.profile_path, managed_user_name: managed_user.name })
      end

      private

      def updated_user
        @updated_user ||= Decidim::UserPresenter.new(resource.current_user)
      end

      def managed_user
        @managed_user ||= Decidim::UserPresenter.new(resource.managed_user)
      end
    end
  end
end
