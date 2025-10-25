# frozen_string_literal: true

module Decidim
  module Debates
    class DebateMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "DebateMutation"
      description "a debate which includes its available mutations"

      field :update, mutation: Decidim::Debates::UpdateDebateType, description: "Updates a debate"
    end
  end
end
