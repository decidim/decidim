# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceForm < Decidim::Form
      mimic :dummy_resource

      attribute :title, String
      attribute :body, String

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }
    end
  end
end
