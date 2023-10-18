# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the assembly card for an instance of an Assembly
    # the default size is the Grid Card (:g)
    class AssemblyCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/assemblies/assembly_s"
        else
          "decidim/assemblies/assembly_g"
        end
      end
    end
  end
end
