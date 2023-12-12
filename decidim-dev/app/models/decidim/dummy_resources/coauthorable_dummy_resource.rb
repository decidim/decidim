# frozen_string_literal: true

module Decidim
  module DummyResources
    class CoauthorableDummyResource < ApplicationRecord
      self.table_name = "decidim_dummy_resources_coauthorable_dummy_resources"

      include ::Decidim::Coauthorable
      include HasComponent
    end
  end
end
