# frozen_string_literal: true

module Decidim
  module Pages
    # Importer for Pages specific data (i.e. its page content).
    class DataImporter < Decidim::Importers::Importer
      def initialize(component)
        @component = component
      end

      # Creates a new Decidim::Pages::Page associated to the given **component**
      # for the serialized page object.
      #
      # @param serialized [Hash] The serialized data read from the import file.
      # @param _user [Decidim::User] The user performing the import.
      # @return [Decidim::Pages::Page] The imported page
      def import(serialized, _user)
        Page.create!(
          component: @component,
          body: serialized["body"]
        )
      end
    end
  end
end
