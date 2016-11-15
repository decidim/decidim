# frozen_string_literal: true
module Decidim
  module Pages
    module Admin
      class UpdatePage < Rectify::Command
        def initialize(form, component)
          @component = component
          @page = Page.new(component)
          @form = form
        end

        def call
          return broadcast(:invalid) if @form.invalid?

          update_page
          broadcast(:ok)
        end

        private

        attr_reader :handler

        def update_page
          @page.content = @form.attributes
          @page.save!
        end
      end
    end
  end
end
