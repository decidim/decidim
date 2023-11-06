# frozen_string_literal: true

module Decidim
  module DummyResources
    class NestedDummyResource < ApplicationRecord
      include Decidim::Resourceable
      belongs_to :dummy_resource
    end
  end
end
