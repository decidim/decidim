# frozen_string_literal: true

module Decidim
  module AssemblyRoleConfig
    class Valuator < Base
      def component_is_whitelisted?(manifest)
        manifest.to_sym == :proposals
      end
    end
  end
end
