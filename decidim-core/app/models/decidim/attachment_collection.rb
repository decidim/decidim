# frozen_string_literal: true

module Decidim
  # Categories serve as a taxonomy for attachments to use for while in the
  # context of a participatory space.
  class AttachmentCollection < ApplicationRecord
    include Traceable
    include Decidim::TranslatableResource

    translatable_fields :name, :description
    belongs_to :collection_for, polymorphic: true
    has_many :attachments, class_name: "Decidim::Attachment", dependent: :nullify

    delegate :organization, to: :collection_for

    default_scope { order(arel_table[:weight].asc) }

    def unused?
      attachments.empty?
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::AttachmentCollectionPresenter
    end
  end
end
