# frozen_string_literal: true

module Decidim
  module Dev
    class NestedDummyResource < ApplicationRecord
      self.table_name = "decidim_dummy_resources_nested_dummy_resources"
      include Decidim::Resourceable
      belongs_to :dummy_resource
    end
  end
end
