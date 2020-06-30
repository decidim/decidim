# frozen_string_literal: true

module Decidim
  class TranslatedField < ApplicationRecord
    belongs_to :translated_resource, foreign_key: "translated_resource_id", foreign_type: "translated_resource_type", polymorphic: true, optional: true
  end
end
