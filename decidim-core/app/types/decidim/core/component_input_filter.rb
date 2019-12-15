# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputFilter < BaseInputFilter
      include HasPublishableInputFilter

      graphql_name "ComponentFilter"
      description "A type used for filtering any generic component"
    end
  end
end
