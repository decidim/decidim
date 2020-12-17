# frozen_string_literal: true

module Decidim
  module Admin
    class ImportForm < Form
      ACCEPTED_MIME_TYPES = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES
      MIME_TYPE_ZIP = "application/zip"

      attribute :file
    end
  end
end
