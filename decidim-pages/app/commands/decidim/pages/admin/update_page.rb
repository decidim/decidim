# frozen_string_literal: true
module Decidim
  module Pages
    module Admin
      # This command is executed when the user changes a Page from the admin
      # panel.
      class UpdatePage < Rectify::Command
        # Initializes a UpdatePage Command.
        #
        # form - The form from which to get the data.
        # page - The current instance of the page to be updated.
        def initialize(form, page)
          @form = form
          @page = page
        end

        # Updates the page if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          update_page
          broadcast(:ok)
        end

        private

        def update_page
          @page.update_attributes!(body: @form.body)
        end
      end
    end
  end
end
