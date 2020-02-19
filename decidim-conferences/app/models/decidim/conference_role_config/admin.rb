# frozen_string_literal: true

module Decidim
  module ConferenceRoleConfig
    class Admin < Base
      def component_is_whitelisted?(_manifest)
        true
      end
    end
  end
end
