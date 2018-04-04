# frozen_string_literal: true

module Decidim
  module Core
    AttachmentType = GraphQL::ObjectType.define do
      name "Attachment"
      description "A file attachment"

      field :url, !types.String, "The url of this attachment"
      field :type, !types.String, "The type of this attachment", property: :file_type
      field :thumbnail, types.String, "A thumbnail of this attachment, if it's an image.", property: :thumbnail_url
    end
  end
end
