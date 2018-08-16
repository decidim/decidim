# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the assembly card for an instance of an Assembly
    # the default size is the Medium Card (:m)
    class AssemblyCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/assemblies/assembly_m"
      end
    end
  end
end
