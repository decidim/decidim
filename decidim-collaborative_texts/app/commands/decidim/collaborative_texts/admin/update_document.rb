# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a Document from the admin
      # panel.
      class UpdateDocument < Decidim::Commands::UpdateResource
        fetch_form_attributes :title
      end
    end
  end
end
