# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class AccessModeEnum < Decidim::Api::Types::BaseEnum
        description "The access modes for participatory spaces"

        value "OPEN", value: "open", description: "Open to everyone"
        value "TRANSPARENT", value: "transparent", description: "Transparent (visible but restricted participation)"
        value "RESTRICTED", value: "restricted", description: "Restricted to members only"
      end
    end
  end
end
