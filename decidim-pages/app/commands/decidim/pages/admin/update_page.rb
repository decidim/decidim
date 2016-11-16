# frozen_string_literal: true
module Decidim
  module Pages
    module Admin
      class UpdatePage < Rectify::Command
        def initialize(form, page)
          @page = page
          @form = form
        end

        def call
          return broadcast(:invalid) if @form.invalid?

          update_page
          broadcast(:ok)
        end

        private

        def update_page
          @page.update_attributes!(
            title: @form.title,
            body: @form.body
          )
        end
      end
    end
  end
end
