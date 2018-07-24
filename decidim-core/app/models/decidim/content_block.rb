# frozen_string_literal: true

module Decidim
  class ContentBlock < ApplicationRecord
    # We're tricking the attachments system, as we need to give a name to each
    # attachment (image names are defined in the content block manifest), but the
    # current attachments do not allow this, so we'll use the attachment `title`
    # field to identify each image.
    include HasAttachments

    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"
  end
end
