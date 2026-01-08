# frozen_string_literal: true

module Decidim
  module Debates
    class DebateMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "DebateMutation"
      description "A debate which includes its available mutations"

      field :close, mutation: Decidim::Debates::CloseDebateType, description: "Closes a debate"
      field :create_debate, mutation: Decidim::Debates::CreateDebateType, description: "Creates a debate"
    end
  end
end
