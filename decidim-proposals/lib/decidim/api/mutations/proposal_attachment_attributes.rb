# frozen_string_literal: true

module Decidim
  module Proposals
    # The file sent with a proposal through a multipart request.
    #
    # Only the fields the proposal form consumes are accepted here: the upload is
    # stored as a blob and the attachment record is created by the command through
    # `Decidim::MultipleAttachmentsMethods`, which uses the title as a plain string
    # in the current locale.
    class ProposalAttachmentAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProposalAttachmentAttributes"
      description "Attributes for a file uploaded with a proposal"

      argument :file, Decidim::Api::Types::BaseUpload, "The file to upload and attach", required: true
      argument :title, GraphQL::Types::String, "The title of the attachment", required: false
    end
  end
end
