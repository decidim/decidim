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

      # REDESIGN_DETAILS: size :m will be deprecated
      def card_size
        case @options[:size]
        when :m
          "decidim/assemblies/assembly_m"
        else
          "decidim/assemblies/assembly_g"
        end
      end
    end
  end
end
