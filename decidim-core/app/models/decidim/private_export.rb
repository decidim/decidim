# frozen_string_literal: true

module Decidim
  class PrivateExport < ApplicationRecord
    belongs_to :attached_to, polymorphic: true

    has_one_attached :file
    validates :content_type, presence: true

    before_validation :set_content_type_and_size, if: :attached?
    delegate :attached?, to: :file

    default_scope { order(created_at: :desc) }

    def expired?
      expires_at < Time.zone.now
    end

    def set_content_type_and_size
      self.content_type = file.content_type
      self.file_size = file.byte_size
    end
  end
end
