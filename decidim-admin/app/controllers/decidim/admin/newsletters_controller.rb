# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class NewslettersController < ApplicationController
      def index
        authorize! :index, Newsletter
        @newsletters = collection
      end

      private

      def collection
        Newsletter.all
      end
    end
  end
end
