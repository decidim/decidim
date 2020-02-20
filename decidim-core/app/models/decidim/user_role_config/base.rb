# frozen_string_literal: true

module Decidim
  module UserRoleConfig
    class Base
      def initialize(user_role)
        @user_role = user_role
      end

      # Checks whether the given manifest name is accepted for this role.
      #
      # Returns a boolean.
      def component_is_whitelisted?(manifest_name)
        return true if accepted_components == [:all]

        accepted_components.include?(manifest_name)
      end

      # Public: Lists the names of the accepted components for this role.
      #
      # Returns an Array of Symbols.
      def accepted_components
        [:all]
      end

      private

      attr_reader :user_role
    end
  end
end
