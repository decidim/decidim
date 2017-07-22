# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # an assembly.
      class ExportsController < Decidim::Admin::ExportsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
