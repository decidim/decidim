# frozen_string_literal: true

module Decidim
  module UserRoleConfig
    class Base
      def initialize(user_role)
        @user_role = user_role
      end

      def component_is_whitelisted?(_manifest)
        true
      end

      private

      attr_reader :user_role
    end
  end
end
