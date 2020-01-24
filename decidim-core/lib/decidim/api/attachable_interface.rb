# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a attachable object.
    AttachableInterface = GraphQL::InterfaceType.define do
      name "AttachableInterface"
      description "An interface that can be used in objects with attachments"

      field :attachments, !types[Decidim::Core::AttachmentType], "This object's attachments"
    end
  end
end
