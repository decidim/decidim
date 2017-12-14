# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be able to create
  # links from it to another resource.
  module HasAttachmentCollections
    extend ActiveSupport::Concern

    included do
      has_many :attachment_collections,
               class_name: "Decidim::AttachmentCollection",
               foreign_key: "decidim_participatory_space_id",
               foreign_type: "decidim_participatory_space_type",
               dependent: :destroy,
               as: :participatory_space
    end
  end
end
