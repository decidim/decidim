# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class CollaborativeTextsController < Admin::ApplicationController
        helper_method :collaborative_texts
        def index; end

        private

        def collaborative_texts
          @collaborative_texts ||= Document.where(component: current_component)
        end
      end
    end
  end
end
