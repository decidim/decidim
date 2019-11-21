# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to update the current organization from the admin
    # dashboard.
    #
    class OrganizationForm < Form
      include TranslatableAttributes

      mimic :organization

      attribute :name, String
      attribute :reference_prefix, String
      attribute :twitter_handler, String
      attribute :facebook_handler, String
      attribute :instagram_handler, String
      attribute :youtube_handler, String
      attribute :github_handler, String
      attribute :default_locale, String
      attribute :badges_enabled, Boolean
      attribute :user_groups_enabled, Boolean

      attribute :send_welcome_notification, Boolean
      attribute :customize_welcome_notification, Boolean

      translatable_attribute :welcome_notification_subject, String
      translatable_attribute :welcome_notification_body, String

      translatable_attribute :admin_terms_of_use_body, String

      validates :welcome_notification_subject, :welcome_notification_body, translatable_presence: true, if: proc { |form| form.customize_welcome_notification }

      validates :name, presence: true
      validates :default_locale, :reference_prefix, presence: true
      validates :default_locale, inclusion: { in: :available_locales }
      validates :admin_terms_of_use_body, translatable_presence: true

      private

      def available_locales
        current_organization.available_locales
      end
    end
  end
end
