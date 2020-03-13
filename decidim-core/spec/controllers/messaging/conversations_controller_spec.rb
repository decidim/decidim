# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Messaging::ConversationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }

    let(:conversation) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [create(:user)],
        body: "Hi!"
      )
    end

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "GET new" do
      context "when is the same user" do
        subject { get :new, params: { recipient_id: user.id } }

        it "redirects to the profile path" do
          expect(subject).to redirect_to profile_path(user.nickname)
        end
      end
    end

    describe "POST create" do
      context "when invalid" do
        it "redirects the user back" do
          post :create, params: { recipient_id: 999, body: "" }

          expect(response).to redirect_to("/")
        end
      end
    end

    describe "PUT update" do
      context "when invalid" do
        it "renders an error message" do
          put :update, format: :js, params: { id: conversation.id, message: { body: "A" * 1001 } }

          expect(response.body).to include("Message not sent")
        end
      end
    end
  end
end
