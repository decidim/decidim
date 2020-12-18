# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      autoload :ImporterFactory, "decidim/admin/import/importer_factory"
      autoload :Importer, "decidim/admin/import/importer"
      autoload :Parser, "decidim/admin/import/parser"
      autoload :Readers, "decidim/admin/import/readers"
    end
  end
end
