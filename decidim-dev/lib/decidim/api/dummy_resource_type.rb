# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourceType < Decidim::Api::Types::BaseObject
      graphql_name "DummyResource"
      description "A dummy resource to allow testing the API against the dummy resources."

      implements Decidim::Comments::CommentableInterface
    end
  end
end
