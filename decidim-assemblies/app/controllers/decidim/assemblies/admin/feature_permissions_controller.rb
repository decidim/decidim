# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Feature
      # permissions in the admin panel.
      #
      class FeaturePermissionsController < Decidim::Admin::FeaturePermissionsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
