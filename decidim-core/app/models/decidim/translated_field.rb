# frozen_string_literal: true

module Decidim
  class TranslatedField < ApplicationRecord
    belongs_to :translated_resource, foreign_key: "decidim_fields_id", foreign_type: "decidim_fields_type", polymorphic: true, optional: true
  end
end
