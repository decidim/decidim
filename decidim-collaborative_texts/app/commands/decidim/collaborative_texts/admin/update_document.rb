# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a CollaborativeText from the admin
      # panel.
      class UpdateDocument < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :accepting_suggestions, :announcement
      end
    end
  end
end
