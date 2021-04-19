# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceForm < Decidim::Form
      include Decidim::AttachmentAttributes

      mimic :dummy_resource

      attribute :title, String
      attribute :body, String
      attribute :attachment, AttachmentForm

      attachments_attribute :photos

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { in: 15..150 }
    end
  end
end
