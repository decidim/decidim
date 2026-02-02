# frozen_string_literal: true

module Decidim
  module Debates
    class DebateMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "DebateMutation"
      description "A debate which includes its available mutations"

      field :close, mutation: Decidim::Debates::CloseDebateType, description: "Closes a debate"
      field :update, mutation: Decidim::Debates::UpdateDebateType, description: "Updates a debate"
    end
  end
end
