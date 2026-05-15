# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a Document from the admin
      # panel.
      class UpdateDocumentSettings < Decidim::Commands::UpdateResource
        fetch_form_attributes :announcement
      end
    end
  end
end
