# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows importing things.
      # It is targeted for customizations for importing things that lives under
      # an assembly.
      class ImportsController < Decidim::Admin::ImportsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
