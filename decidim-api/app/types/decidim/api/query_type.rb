# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root query type of the whole API.
    class QueryType < Decidim::Api::Types::BaseObject
      description "The root query of this schema"
    end
  end
end
