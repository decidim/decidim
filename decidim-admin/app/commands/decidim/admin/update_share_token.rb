# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to update a taxonomy.
    # This command is called from the controller.
    class UpdateShareToken < Decidim::Commands::UpdateResource
      fetch_form_attributes :token, :expires_at
    end
  end
end
