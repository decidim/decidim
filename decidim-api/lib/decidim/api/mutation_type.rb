# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    class MutationType < Decidim::Api::Types::BaseObject
      description "The root mutation of this schema"

      required_scopes "api:write"
    end
  end
end
