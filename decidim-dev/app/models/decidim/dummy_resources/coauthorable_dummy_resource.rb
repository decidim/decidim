# frozen_string_literal: true

module Decidim
  module DummyResources
    class CoauthorableDummyResource < ApplicationRecord
      include ::Decidim::Coauthorable
      include HasComponent
    end
  end
end
