# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a category in the
    # system.
    class UpdateCategory < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :weight, :parent_id
    end
  end
end
