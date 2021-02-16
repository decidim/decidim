# frozen_string_literal: true

module Decidim
  module Votings
    class ContentBlockCell < Decidim::Admin::ContentBlockCell
      delegate :scoped_resource, to: :controller

      def edit_content_block_path
        decidim_votings.edit_voting_landing_page_content_block_path(scoped_resource, manifest_name)
      end

      def decidim_votings
        Decidim::Votings::AdminEngine.routes.url_helpers
      end
    end
  end
end
