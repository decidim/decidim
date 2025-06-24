# frozen_string_literal: true

module Decidim
  module Blogs
    # This command is executed when the user updates a Post from the frontend
    class UpdatePost < Decidim::Commands::UpdateResource
      fetch_form_attributes :title, :body

      private

      def resource_class = Decidim::Blogs::Post

      def attributes
        super.merge(
          title: { I18n.locale => form.title },
          body: { I18n.locale => form.body }
        )
      end
    end
  end
end
