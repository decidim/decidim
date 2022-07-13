# frozen_string_literal: true

module Decidim
  module Core
    class QuantifiableTranslatedFieldType < Decidim::Api::Types::BaseObject
      description "A quantifiable translated field with singular and plural formats"

      field :single, Decidim::Core::TranslatedFieldType, "The singular format.", null: false
      field :plural, Decidim::Core::TranslatedFieldType, "The plural format.", null: false
    end
  end
end
