# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
