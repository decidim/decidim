# frozen_string_literal: true

module Decidim
  module DummyResources
    class NestedDummyResource < ApplicationRecord
      self.table_name = "decidim_dummy_resources_nested_dummy_resources"
      include Decidim::Resourceable
      belongs_to :dummy_resource
    end
  end
end
