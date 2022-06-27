# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentsController, type: :controller do
      routes { Decidim::Comments::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component:) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        it "renders the index template" do
          get :index, xhr: true, params: { commentable_gid: commentable.to_signed_global_id.to_s }
          expect(subject).to render_template(:index)
        end

        it "tells devise not to reset timeout counter" do
          expect(request.env["devise.skip_timeoutable"]).to be_nil
          get :index, xhr: true, params: { commentable_gid: commentable.to_signed_global_id.to_s }
          expect(request.env["devise.skip_timeoutable"]).to be(true)
        end

        context "when requested without an XHR request" do
          it "redirects to the commentable" do
            get :index, params: { commentable_gid: commentable.to_signed_global_id.to_s }
            expect(subject).to redirect_to(
              Decidim::ResourceLocatorPresenter.new(commentable).path
            )
          end
        end

        context "when the reload parameter is given" do
          it "renders the reload template" do
            get :index, xhr: true, params: { commentable_gid: commentable.to_signed_global_id.to_s, reload: 1 }
            expect(subject).to render_template(:reload)
          end
        end

        context "when comments are disabled for the component" do
          let(:component) { create(:component, :with_comments_disabled, participatory_space: participatory_process) }

          it "redirects with a flash alert" do
            get :index, xhr: true, params: { commentable_gid: commentable.to_signed_global_id.to_s }
            expect(flash[:alert]).to be_present
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      describe "POST create" do
        let(:comment_alignment) { 0 }
        let(:comment_params) do
          {
            commentable_gid: commentable.to_signed_global_id.to_s,
            body: "This is a new comment",
            alignment: comment_alignment
          }
        end

        it "responds with unauthorized status" do
          post :create, xhr: true, params: { comment: comment_params }
          expect(response).to have_http_status(:unauthorized)
        end

        context "when the user is signed in" do
          let(:user) { create(:user, :confirmed, locale: "en", organization:) }
          let(:comment) { Decidim::Comments::Comment.last }

          before do
            sign_in user, scope: :user
          end

          it "creates the comment" do
            expect do
              post :create, xhr: true, params: { comment: comment_params }
            end.to change(Decidim::Comments::Comment, :count).by(1)

            expect(comment.body.values.first).to eq("This is a new comment")
            expect(comment.alignment).to eq(comment_alignment)
            expect(subject).to render_template(:create)
          end

          context "when requested without an XHR request" do
            it "throws an unknown format exception" do
              expect do
                post :create, params: { comment: comment_params }
              end.to raise_error(ActionController::UnknownFormat)
            end
          end

          context "when comments are disabled for the component" do
            let(:component) { create(:component, :with_comments_disabled, participatory_space: participatory_process) }

            it "redirects with a flash alert" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when trying to comment on a private space where the user is not assigned to" do
            let(:participatory_process) { create :participatory_process, :private, organization: }

            it "redirects with a flash alert" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when comment alignment is positive" do
            let(:comment_alignment) { 1 }

            it "creates the comment with the alignment defined as 1" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to change(Decidim::Comments::Comment, :count).by(1)

              expect(comment.alignment).to eq(comment_alignment)
              expect(subject).to render_template(:create)
            end
          end

          context "when comment alignment is negative" do
            let(:comment_alignment) { -1 }

            it "creates the comment with the alignment defined as -1" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to change(Decidim::Comments::Comment, :count).by(1)

              expect(comment.alignment).to eq(comment_alignment)
              expect(subject).to render_template(:create)
            end
          end

          context "when comment body is missing" do
            let(:comment_params) do
              {
                commentable_gid: commentable.to_signed_global_id.to_s,
                alignment: comment_alignment
              }
            end

            it "renders the error template" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(subject).to render_template(:error)
            end

            context "when requested without an XHR request" do
              it "throws an unknown format exception" do
                expect do
                  post :create, params: { comment: comment_params }
                end.to raise_error(ActionController::UnknownFormat)
              end
            end
          end

          context "when comment alignment is invalid" do
            let(:comment_alignment) { 2 }

            it "renders the error template" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(subject).to render_template(:error)
            end
          end

          context "when the comment does not exist" do
            let(:comment_params) do
              {
                commentable_gid: "unexisting",
                body: "This is a new comment",
                alignment: 0
              }
            end

            it "raises a routing error" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to raise_error(ActionController::RoutingError)
            end
          end
        end
      end

      describe "DELETE destroy" do
        let(:user) { create(:user, :confirmed, locale: "en", organization:) }
        let(:comment_author) { create(:user, :confirmed, locale: "en", organization:) }
        let!(:comment) { create(:comment, commentable:, author: comment_author) }

        it "redirects to sign in path" do
          expect do
            delete :destroy, xhr: true, params: { id: comment.id }
          end.not_to(change { Decidim::Comments::Comment.not_deleted.count })

          expect(response).to redirect_to("/users/sign_in")
        end

        context "when a user different of the author is signed in" do
          before do
            sign_in user, scope: :user
          end

          it "doesn't delete the comment" do
            expect do
              delete :destroy, xhr: true, params: { id: comment.id }
            end.not_to(change { Decidim::Comments::Comment.not_deleted.count })

            expect(response).not_to have_http_status(:success)
          end
        end

        context "when the author is signed in" do
          before do
            sign_in comment_author, scope: :user
          end

          it "deletes the comment" do
            expect do
              delete :destroy, xhr: true, params: { id: comment.id }
            end.to change { Decidim::Comments::Comment.not_deleted.count }.by(-1)

            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end
