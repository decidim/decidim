# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process type in the system.
      class CreateParticipatoryProcessType < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :organization

        protected

        def resource_class = Decidim::ParticipatoryProcessType
      end
    end
  end
end
