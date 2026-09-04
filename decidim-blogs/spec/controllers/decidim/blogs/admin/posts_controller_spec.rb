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

        describe "GET index" do
          let!(:oldest_created_latest_published) do
            create(:post, component:, created_at: 2.days.ago, published_at: 1.hour.ago)
          end
          let!(:latest_created_oldest_published) do
            create(:post, component:, created_at: 1.hour.ago, published_at: 2.days.ago)
          end

          it "lists posts ordered by publication time, most recent first" do
            get :index

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
            expect(controller.posts.to_a).to eq([oldest_created_latest_published, latest_created_oldest_published])
          end
        end
      end
    end
  end
end
