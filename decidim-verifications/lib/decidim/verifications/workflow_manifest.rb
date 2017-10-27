# frozen_string_literal: true

module Decidim
  module Verifications
    class WorkflowManifest
      include ActiveModel::Model
      include Virtus.model

      attribute :engine, Rails::Engine
      attribute :admin_engine, Rails::Engine
      attribute :form, String

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
        I18n.t("#{key}.name", scope: "decidim.authorization_handlers")
      end

      def description
        "#{fullname} (#{I18n.t(type, scope: "decidim.authorization_handlers")})"
      end
    end
  end
end
