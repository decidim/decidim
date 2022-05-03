# frozen_string_literal: true

require "decidim/settings_manifest"

module Decidim
  module Verifications
    autoload :DefaultActionAuthorizer, "decidim/verifications/default_action_authorizer"

    #
    # This class serves as a DSL to declaratively specify a verification method.
    #
    # To define a direct verification method, you need to specify the `form`
    # attribute as a `Decidim::Form` that will be valid if the authorization is
    # valid.
    #
    # To define a deferred verification method, you need specify the `engine`
    # attribute as a full `Rails::Engine` (and optionally another engine for the
    # admin side as the `admin_engine` attribute). The verification will succeed
    # once the engine creates a valid authorization for the method with the
    # `granted_at` column set in DB.
    #
    # Note that whereas direct methods can be used for "on the fly"
    # verification, deferred methods require the authorization status to be
    # persisted into DB. That's the reason why only direct methods can be used
    # for user impersonation, for example, since they require continuous "on the
    # fly" verification by the impersonating user.
    #
    class WorkflowManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      attribute :engine, Rails::Engine, **{}
      attribute :admin_engine, Rails::Engine, **{}
      attribute :form, String
      attribute :expires_in, ActiveSupport::Duration, default: 0.minutes
      attribute :action_authorizer, String
      attribute :renewable, Boolean, default: true
      attribute :time_between_renewals, ActiveSupport::Duration, default: 1.day
      attribute :metadata_cell, String, default: "decidim/verifications/authorization_metadata"

      validate :engine_or_form

      attribute :name, String
      validates :name, presence: true

      def engine_or_form
        engine || form
      end

      def type
        form ? "direct" : "multistep"
      end

      alias key name

      def fullname
        I18n.t("#{key}.name", scope: "decidim.authorization_handlers", default: name.humanize)
      end

      def description
        "#{fullname} (#{I18n.t(type, scope: "decidim.authorization_handlers")})"
      end

      def action_authorizer_class
        if action_authorizer.present?
          action_authorizer.constantize
        else
          DefaultActionAuthorizer
        end
      end

      # Public: Adds configurable settings for this verification workflow. It
      # uses the DSL specified under `Decidim::SettingsManifest`.
      #
      # &block - The DSL present on `Decidim::SettingsManifest`
      #
      # Examples:
      #
      #   workflow.options do |options|
      #     options.attribute :minimum_age, type: :integer, default: 18
      #   end
      #
      # Returns nothing.
      def options
        @options ||= SettingsManifest.new

        yield(@options) if block_given?

        @options
      end
    end
  end
end
