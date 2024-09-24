# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe PostsController do
        include Decidim::ApplicationHelper

        routes { Decidim::Blogs::AdminEngine.routes }

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

        describe "PATCH soft_delete" do
          it "soft deletes the post" do
            expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(post, current_user).and_call_original

            patch :soft_delete, params: { id: post.id }

            expect(response).to redirect_to(posts_path)
            expect(flash[:notice]).to eq(I18n.t("posts.soft_delete.success", scope: "decidim.blogs.admin"))
            expect(post.reload.deleted_at).not_to be_nil
          end
        end

        describe "PATCH restore" do
          before do
            post.update!(deleted_at: Time.current)
          end

          it "restores the post" do
            expect(Decidim::Commands::RestoreResource).to receive(:call).with(post, current_user).and_call_original

            patch :restore, params: { id: post.id }

            expect(response).to redirect_to(posts_path)
            expect(flash[:notice]).to eq(I18n.t("posts.restore.success", scope: "decidim.blogs.admin"))
            expect(post.reload.deleted_at).to be_nil
          end
        end

        describe "GET deleted" do
          let!(:deleted_post) { create(:post, component:, deleted_at: Time.current) }
          let!(:active_post) { create(:post, component:) }
          let(:deleted_posts) { controller.view_context.deleted_posts }

          it "lists only deleted posts" do
            get :manage_trash

            expect(response).to have_http_status(:ok)
            expect(deleted_posts).not_to include(active_post)
            expect(deleted_posts).to include(deleted_post)
          end

          it "renders the deleted posts template" do
            get :manage_trash

            expect(response).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
