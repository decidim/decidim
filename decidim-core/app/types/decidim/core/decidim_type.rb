# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class DecidimType < Decidim::Api::Types::BaseObject
      description "Decidim's framework-related properties."

      field :version, String, "The current decidim's version of this deployment.", null: false
      field :application_name, String, "The current installation's name.", null: false
    end
  end
end
