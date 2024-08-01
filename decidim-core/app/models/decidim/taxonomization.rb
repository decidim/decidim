# frozen_string_literal: true

module Decidim
  # Represents the link between a taxonomy and any taxonomizable entity.
  class Taxonomization < ApplicationRecord
    belongs_to :taxonomy,
               class_name: "Decidim::Taxonomy",
               counter_cache: :taxonomizations_count,
               inverse_of: :taxonomizations

    belongs_to :taxonomizable, polymorphic: true
  end
end
