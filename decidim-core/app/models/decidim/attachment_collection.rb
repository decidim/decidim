# frozen_string_literal: true

module Decidim
  # Categories serve as a taxonomy for attachments to use for while in the
  # context of a participatory space.
  class AttachmentCollection < ApplicationRecord
    include Decidim::TranslatableResource

    translatable_fields :name, :description
    belongs_to :collection_for, polymorphic: true
    has_many :attachments, class_name: "Decidim::Attachment", dependent: :nullify

    default_scope { order(arel_table[:weight].asc) }

    def unused?
      attachments.empty?
    end
  end
end
