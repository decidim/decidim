# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a participatory space
    # private user.
    class UpdateParticipatorySpacePrivateUser < Decidim::Commands::UpdateResource
      fetch_form_attributes :role, :published
    end
  end
end
