# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceForm < Decidim::Form
      mimic :dummy_resource

      attribute :title, String
      attribute :body, String
      attribute :attachment, AttachmentForm
      attribute :photos, Array[String]
      attribute :add_photos, Array

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }
    end
  end
end
