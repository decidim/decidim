# frozen_string_literal: true

module Decidim
  module Dev
    class NestedDummyResource < ApplicationRecord
      include Decidim::Resourceable
      belongs_to :dummy_resource
    end
  end
end
