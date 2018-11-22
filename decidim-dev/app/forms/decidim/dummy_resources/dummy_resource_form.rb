# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceForm < Decidim::Form
      mimic :dummy_resource

      attribute :title, String

      validate :title, presence: true
    end
  end
end
