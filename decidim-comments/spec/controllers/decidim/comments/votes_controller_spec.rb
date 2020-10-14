# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe VotesController, type: :controller do
      routes { Decidim::Comments::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component: component) }
      let(:comment) { create(:comment, commentable: commentable) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "POST create" do
        it "responds with unauthorized status" do
          post :create, xhr: true, params: { comment_id: comment.id, weight: 1 }
          expect(response).to have_http_status(:unauthorized)
        end

        context "when the user is signed in" do
          let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }

          before do
            sign_in user, scope: :user
          end

          context "when vote weight is positive" do
            it "adds an upvote to the comment" do
              post :create, xhr: true, params: { comment_id: comment.id, weight: 1 }
              expect(comment.up_voted_by?(user)).to be(true)
              expect(comment.up_votes.count).to eq(1)
              expect(subject).to render_template(:create)
            end
          end

          context "when vote weight is negative" do
            it "adds a downvote to the comment" do
              post :create, xhr: true, params: { comment_id: comment.id, weight: -1 }
              expect(comment.down_voted_by?(user)).to be(true)
              expect(comment.down_votes.count).to eq(1)
              expect(subject).to render_template(:create)
            end
          end

          context "when vote weight is invalid" do
            it "renders the error template" do
              post :create, xhr: true, params: { comment_id: comment.id, weight: 0 }
              expect(comment.up_voted_by?(user)).to be(false)
              expect(comment.up_votes.count).to eq(0)
              expect(comment.down_voted_by?(user)).to be(false)
              expect(comment.down_votes.count).to eq(0)
              expect(subject).to render_template(:error)
            end
          end

          context "when the comment does not exist" do
            it "raises a routing error" do
              last_id = Decidim::Comments::Comment.last&.id || 0
              expect do
                post :create, xhr: true, params: { comment_id: last_id + 1, weight: 1 }
              end.to raise_error(ActionController::RoutingError)
            end
          end
        end
      end
    end
  end
end
