# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders a list of assemblies in content blocks
    class AssembliesCell < Decidim::ViewModel
      include Decidim::CardHelper

      alias assemblies model

      def total_count
        @total_count ||= options[:total_count] || assemblies.count
      end

      def show_all_path
        @show_all_path ||= options[:show_all_path].presence
      end
    end
  end
end
