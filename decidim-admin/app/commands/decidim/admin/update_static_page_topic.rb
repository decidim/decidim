# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a static page topic.
    class UpdateStaticPageTopic < Decidim::Commands::UpdateResource
      fetch_form_attributes :title, :description, :show_in_footer, :weight
    end
  end
end
