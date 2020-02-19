# frozen_string_literal: true

module Decidim
  module ConferenceRoleConfig
    class ConferenceAdmin < Base
      def component_is_whitelisted?(_manifest)
        true
      end
    end
  end
end
