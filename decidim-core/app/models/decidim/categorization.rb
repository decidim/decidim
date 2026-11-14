# frozen_string_literal: true

module Decidim
  class Categorization < ApplicationRecord
    include Decidim::Traceable

    belongs_to :category, foreign_key: :decidim_category_id, inverse_of: :categorizations
    belongs_to :categorizable, polymorphic: true
  end
end
