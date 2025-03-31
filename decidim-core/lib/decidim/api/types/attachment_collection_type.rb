# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionType < Decidim::Api::Types::BaseObject
      description "A file attachment collection"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this AttachmentCollection.", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this AttachmentCollection.", null: false

      field :attachments, [Decidim::Core::AttachmentType, { null: true }], "This object's attachments", null: false
    end
  end
end
