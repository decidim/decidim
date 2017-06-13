# frozen_string_literal: true

module Decidim
  class Categorization < ApplicationRecord
    belongs_to :category, foreign_key: :decidim_category_id
    belongs_to :categorizable, polymorphic: true
  end
end
