# frozen_string_literal: true
require "decidim/api/engine"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    autoload :MutationType, "decidim/api/types/mutation"
    autoload :QueryType, "decidim/api/types/query"
    autoload :AuthorInterface, "decidim/api/types/author_interface"

    autoload :TranslatedFieldType, "decidim/api/types/translated_field"
    autoload :LocalizedStringType, "decidim/api/types/localized_string"

    autoload :Schema, "decidim/api/schema"
  end
end
