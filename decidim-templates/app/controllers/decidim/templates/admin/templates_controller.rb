# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class TemplatesController < Decidim::Templates::Admin::ApplicationController
        def index
          @templates = Decidim::Templates::Template.all.order(:templatable_type)
        end
      end
    end
  end
end
