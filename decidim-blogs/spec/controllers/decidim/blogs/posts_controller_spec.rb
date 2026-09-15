# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    describe PostsController do
      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let!(:post_component) { create(:post_component, participatory_space: participatory_process) }
      let!(:published) { create(:post, component: post_component, created_at: 2.days.ago, published_at: 2.days.ago) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_component"] = post_component
        request.env["decidim.current_participatory_space"] = participatory_process
      end

      describe "show" do
        context "when the post has not published yet" do
          let!(:unpublished) { create(:post, component: post_component, created_at: 2.days.ago, published_at: 2.days.from_now) }
          let!(:another_published) { create(:post, component: post_component, created_at: 3.days.ago, published_at: 1.day.ago) }
          let!(:current_user) { create(:user, :admin, :confirmed, organization:) }

          it "lists only published posts" do
            get :index
            expect(controller.helpers.posts).to eq([another_published, published])
          end

          it "shows published posts" do
            get :show, params: { id: published.id }
            expect(response).to have_http_status(:ok)
          end

          context "when not logged in" do
            it "throws exception on non published page" do
              expect { get :show, params: { id: unpublished.id } }
                .to raise_error(ActionController::RoutingError)
            end
          end

          context "when non-admin user" do
            before do
              current_user.admin = false
              current_user.save!
              sign_in current_user
            end

            it "throws exception on non published page" do
              expect { get :show, params: { id: unpublished.id } }
                .to raise_error(ActionController::RoutingError)
            end
          end

          context "when admin user" do
            before do
              sign_in current_user
            end

            it "does not throw exception on unpublished page" do
              get :show, params: { id: unpublished.id }
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end

      describe "#destroy" do
        context "when user is not authenticated" do
          it "redirects to login page" do
            delete(:destroy, params: { id: published.id })
            expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
            expect(response).to redirect_to(new_user_session_path)
            expect(published.reload).to be_present
          end
        end
      end

      describe "#new" do
        context "when user is not authenticated" do
          it "redirects to login page" do
            get :new
            expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "#create" do
        context "when user is not authenticated" do
          it "redirects to login page" do
            post(:create, params: { component_id: post_component.id })
            expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "#edit" do
        context "when user is not authenticated" do
          it "redirects to login page" do
            get :edit, params: { component_id: post_component.id, id: published.id }
            expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "#update" do
        context "when user is not authenticated" do
          it "redirects to login page" do
            put :update, params: { component_id: post_component.id, id: published.id }
            expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
