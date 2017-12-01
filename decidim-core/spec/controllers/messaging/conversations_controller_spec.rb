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

    describe "POST create" do
      context "when invalid" do
        it "renders an error message" do
          post :create, params: { recipient_id: 999, body: "" }

          expect(response.body).to include("Conversation not started")
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
