# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceType  < GraphQL::Schema::Object
      graphql_name "ParticipatorySpace"
      implements ParticipatorySpaceInterface

      description "A participatory space"
    end
  end
end
