# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Blogs
    module Admin
      describe PostsController do
        include Decidim::ApplicationHelper

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) do
          create(:post_component, participatory_space:)
        end
        let(:post) { create(:post, component:) }
        let(:params) { { id: post.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        it_behaves_like "a soft-deletable resource",
                        resource_name: :post,
                        resource_path: :posts_path,
                        trash_path: :manage_trash_posts_path
      end
    end
  end
end
