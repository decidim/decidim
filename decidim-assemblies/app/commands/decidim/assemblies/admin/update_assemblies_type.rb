# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating a new assembly
      # type in the system.
      class UpdateAssembliesType < Decidim::Commands::UpdateResource
        fetch_form_attributes :title
      end
    end
  end
end
