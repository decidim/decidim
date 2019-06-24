# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows importing categories for assemblies.
      #
      class CategoriesImportsController < Decidim::Admin::CategoriesImportsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
