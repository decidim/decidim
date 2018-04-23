# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # The main admin application controller for assemblies
      class ApplicationController < Decidim::Admin::ApplicationController
        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
