# frozen_string_literal: true

module Decidim
  module AssemblyRoleConfig
    class Moderator < Base
      def component_is_whitelisted?(_manifest)
        false
      end
    end
  end
end
