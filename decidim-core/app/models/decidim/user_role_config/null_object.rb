# frozen_string_literal: true

module Decidim
  module ParticipatorySpaceRoleConfig
    class NullObject < Base
      def component_is_whitelisted?(_manifest)
        false
      end
    end
  end
end
