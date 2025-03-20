# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process type in the system.
      class UpdateParticipatoryProcessType < Decidim::Commands::UpdateResource
        fetch_form_attributes :title
      end
    end
  end
end
