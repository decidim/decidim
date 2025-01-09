# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a taxonomizable object.
    module TaxonomizableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in taxonomizable objects."

      field :taxonomies, [Decidim::Core::TaxonomyType], "The object's taxonomies", null: true
    end
  end
end
