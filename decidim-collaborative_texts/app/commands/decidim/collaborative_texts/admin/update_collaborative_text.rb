# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a CollaborativeText from the admin
      # panel.
      class UpdateCollaborativeText < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :component
      end
    end
  end
end
