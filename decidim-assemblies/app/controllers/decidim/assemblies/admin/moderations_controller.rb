# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows admins to manage moderations in an assembly.
      class ModerationsController < Decidim::Admin::ModerationsController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
