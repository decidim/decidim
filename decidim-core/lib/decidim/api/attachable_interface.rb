# frozen_string_literal: true

module Decidim
  module Core
    module AttachableInterface
      include GraphQL::Schema::Interface
      # name "AttachableInterface"
      # description "An interface that can be used in objects with attachments"

      field :attachments, [Decidim::Core::AttachmentType], null: false, description: "This object's attachments"
    end
  end
end
