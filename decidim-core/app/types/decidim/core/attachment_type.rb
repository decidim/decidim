# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentType < GraphQL::Schema::Object
      graphql_name "Attachment"
      description "A file attachment"

      field :url, String, null: false, description: "The url of this attachment"
      field :type, String, null: false, description: "The type of this attachment"
      field :thumbnail, String, null: true, description: "A thumbnail of this attachment, if it's an image."

      def type
        object.file_type
      end

      def thumbnail
        object.thumbnail_url
      end
    end
  end
end
