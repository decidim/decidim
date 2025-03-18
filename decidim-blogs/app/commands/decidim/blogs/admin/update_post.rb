# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user changes a Post from the admin
      # panel.
      class UpdatePost < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :body, :author, :taxonomizations

        private

        def attributes
          super.merge(published_at: form.published_at).reject do |attribute, value|
            value.blank? && attribute == :published_at
          end
        end
      end
    end
  end
end
