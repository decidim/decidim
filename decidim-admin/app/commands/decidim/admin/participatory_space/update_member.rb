# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # A command with all the business logic when updating a participatory space
      # member.
      class UpdateMember < Decidim::Commands::UpdateResource
        fetch_form_attributes :role, :published
      end
    end
  end
end
