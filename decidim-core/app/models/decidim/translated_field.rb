# frozen_string_literal: true

module Decidim
  class TranslatedField < ApplicationRecord
    belongs_to :fields, polymorphic: true
  end
end
