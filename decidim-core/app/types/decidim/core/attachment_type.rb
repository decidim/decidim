# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentType < Decidim::Api::Types::BaseObject
      description "A file attachment"

      field :url, String, "The url of this attachment", null: false
      field :type, String, "The type of this attachment", method: :file_type, null: false
      field :thumbnail, String, "A thumbnail of this attachment, if it's an image.", method: :thumbnail_url, null: true
    end
  end
end
