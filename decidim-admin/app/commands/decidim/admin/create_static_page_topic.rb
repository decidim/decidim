# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static page topic.
    class CreateStaticPageTopic < Decidim::Commands::CreateResource
      fetch_form_attributes :title, :description, :show_in_footer, :weight, :organization

      protected

      def resource_class = Decidim::StaticPageTopic
    end
  end
end
