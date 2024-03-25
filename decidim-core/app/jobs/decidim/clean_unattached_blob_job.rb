# frozen_string_literal: true

module Decidim
  class CleanUnattachedBlobJob < ApplicationJob
    def perform(key)
      blob = ActiveStorage::Blob.find_by(key:)

      return if blob.blank?
      return if blob.attachments.any?

      blob.purge
    end
  end
end
