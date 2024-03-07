# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # type in the system.
      class CreateAssembliesType < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :organization

        private

        def resource_class = Decidim::AssembliesType
      end
    end
  end
end
