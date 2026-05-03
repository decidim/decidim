# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly members
      # on assemblies
      class MembersController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::ParticipatorySpace::Concerns::HasMembers
      end
    end
  end
end
