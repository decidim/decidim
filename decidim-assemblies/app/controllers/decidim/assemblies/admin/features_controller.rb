# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Features in the
      # admin panel.
      #
      class FeaturesController < Decidim::Admin::FeaturesController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
