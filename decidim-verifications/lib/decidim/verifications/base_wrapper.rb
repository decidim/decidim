# frozen_string_literal: true

module Decidim
  module Verifications
    class BaseWrapper
      include Rails.application.routes.mounted_helpers

      attr_accessor :entity

      delegate :name, to: :entity

      def initialize(entity)
        @entity = entity
      end

      def fullname
        I18n.t("#{key}.name", scope: "decidim.authorization_handlers")
      end

      def description
        "#{fullname} (#{I18n.t(type, scope: "decidim.authorization_handlers")})"
      end
    end
  end
end
