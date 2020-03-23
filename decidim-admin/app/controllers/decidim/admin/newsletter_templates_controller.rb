# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing newsletters.
    class NewsletterTemplatesController < Decidim::Admin::ApplicationController
      helper_method :templates

      layout "decidim/admin/newsletters"

      def index
        enforce_permission_to :index, :newsletter
      end

      private

      def templates
        @templates ||= Decidim.content_blocks.for(:newsletter_template)
      end
    end
  end
end
