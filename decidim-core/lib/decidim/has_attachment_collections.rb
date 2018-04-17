# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be able to create
  # links from it to another resource.
  module HasAttachmentCollections
    extend ActiveSupport::Concern

    included do
      has_many :attachment_collections,
               class_name: "Decidim::AttachmentCollection",
               dependent: :destroy,
               as: :collection_for
    end
  end
end
