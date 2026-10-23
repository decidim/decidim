# frozen_string_literal: true

module Decidim
  module Debates
    # The file sent with a debate through a multipart request.
    #
    # Only the fields the debate form consumes are accepted here: the upload is
    # stored as a blob and the attachment record is created by the command through
    # `Decidim::MultipleAttachmentsMethods`, which uses the title as a plain string
    # in the current locale.
    class DebateAttachmentAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "DebateAttachmentAttributes"
      description "Attributes for a file uploaded with a debate"

      argument :file, Decidim::Api::Types::BaseUpload, "The file to upload and attach", required: true
      argument :title, GraphQL::Types::String, "The title of the attachment", required: false
    end
  end
end
