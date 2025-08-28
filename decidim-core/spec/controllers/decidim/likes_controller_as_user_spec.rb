# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LikesController do
    include_context "when in a resource"

    describe "As User" do
      context "when likes are enabled" do
        let(:component) { create(:component, :with_likes_enabled) }

        it "allows likes" do
          expect do
            post :create, format: :js, params:
          end.to change(Like, :count).by(1)

          expect(Like.last.author).to eq(user)
          expect(Like.last.resource).to eq(resource)
        end
      end

      context "when likes are disabled" do
        let(:component) { create(:component, :with_likes_disabled) }

        it "does not allow liking" do
          expect do
            post :create, format: :js, params:
          end.not_to change(Like, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      context "when likes are enabled but likes are blocked" do
        let(:component) do
          create(:component, :with_likes_enabled, :with_likes_blocked)
        end

        it "does not allow liking" do
          expect do
            post :create, format: :js, params:
          end.not_to change(Like, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end

    describe "As User unliking a resource" do
      before do
        create(:like, resource:, author: user)
      end

      context "when likes are enabled" do
        let(:component) { create(:component, :with_likes_enabled) }

        it "deletes the like" do
          expect do
            delete :destroy, format: :js, params:
          end.to change(Like, :count).by(-1)

          expect(Like.count).to eq(0)
        end
      end

      context "when likes are disabled" do
        let(:component) { create(:component, :with_likes_disabled) }

        it "does not delete the like" do
          expect do
            delete :destroy, format: :js, params:
          end.not_to change(Like, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
