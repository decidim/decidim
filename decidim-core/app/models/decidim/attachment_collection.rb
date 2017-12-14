# frozen_string_literal: true

module Decidim
  # Categories serve as a taxonomy for attachments to use for while in the
  # context of a participatory space.
  class AttachmentCollection < ApplicationRecord
    belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true
    has_many :attachments, foreign_key: "attachment_collection_id", class_name: "Decidim::Attachment", dependent: :nullify

    def unused?
      attachments.empty?
    end
  end
end
