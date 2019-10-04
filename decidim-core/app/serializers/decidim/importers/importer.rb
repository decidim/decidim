# frozen_string_literal: true

module Decidim
  module Importers
    # This class is an abstraction that defines a common and flexible interface
    # in how importers should be called.
    class Importer

      # Imports the contents of the `serialized` argument.
      #
      # Importers that import JSON will normally accept a JSON valid value for
      # the `serialized` argument.
      # This values may be either: object, array, string, number, true, false
      # or null.
      #
      # Returns: What has been imported.
      #
      # +serialized+: The serialized version of the resource to import.
      # +user+: The Decidim::User that is importing.
      def import(serialized, user)
        raise
         NotImplementedError
      end
    end
  end
end
