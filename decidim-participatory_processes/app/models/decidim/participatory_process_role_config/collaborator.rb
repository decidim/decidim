# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessRoleConfig
    class Collaborator < Base
      def component_is_whitelisted?(_manifest)
        true
      end
    end
  end
end
