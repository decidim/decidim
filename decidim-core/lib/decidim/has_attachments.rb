# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be able to create
  # links from it to another resource.
  module HasAttachments
    extend ActiveSupport::Concern

    included do
      has_many :attachments,
               class_name: "Decidim::Attachment",
               dependent: :destroy,
               inverse_of: :attached_to,
               as: :attached_to

      # All the attachments that are photos for this process.
      #
      # Returns an Array<Attachment>
      def photos
        @photos ||= attachments.select(&:photo?)
      end

      # All the attachments that are documents for this process.
      #
      # Returns an Array<Attachment>
      def documents
        @documents ||= attachments.select(&:document?)
      end
    end
  end
end
