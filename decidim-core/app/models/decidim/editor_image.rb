# frozen_string_literal: true

module Decidim
  # Images attached to editors.
  class EditorImage < ApplicationRecord
    include Decidim::HasUploadValidations

    belongs_to :author, foreign_key: :decidim_author_id, class_name: "Decidim::User", inverse_of: :editor_images
    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

    has_one_attached :file
    validates_upload :file, uploader: Decidim::EditorImageUploader
  end
end
