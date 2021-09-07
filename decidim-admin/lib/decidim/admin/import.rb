# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      autoload :ImporterFactory, "decidim/admin/import/importer_factory"
      autoload :Importer, "decidim/admin/import/importer"
      autoload :Creator, "decidim/admin/import/creator"
      autoload :Readers, "decidim/admin/import/readers"
      autoload :Verifier, "decidim/admin/import/verifier"

      class InvalidFileError < StandardError; end
    end
  end
end
