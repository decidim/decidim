# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing categories for assemblies.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
