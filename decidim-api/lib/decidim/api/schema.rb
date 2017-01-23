# frozen_string_literal: true
module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType
      mutation MutationType

      resolve_type lambda { |obj, _ctx|
        return Decidim::UserType if obj.is_a? Decidim::User
        return Decidim::UserGroupType if obj.is_a? Decidim::UserGroup
      }
    end
  end
end
