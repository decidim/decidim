# frozen_string_literal: true

module Decidim
  class EditorImageForm < Decidim::Form
    mimic :editor_image

    attribute :file
    attribute :author_id, Integer

    validates :author_id, presence: true
    validates :file, presence: true

    alias organization current_organization
  end
end
