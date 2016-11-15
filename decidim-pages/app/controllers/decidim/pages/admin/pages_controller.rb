# frozen_string_literal: true
require "decidim/admin/components/base_controller"

module Decidim
  module Pages
    module Admin
      class PagesController < ApplicationController
        def edit
          page = Page.new(current_component)
          @form = PageForm.new(page.content)
        end

        def update
          @form = Admin::PageForm.from_params(params)
          component = current_component
          UpdatePage.call(@form, component) do
            on(:ok) do
              render action: "edit"
            end

            on(:invalid) do
              render action: "edit"
            end
          end
        end
      end
    end
  end
end
