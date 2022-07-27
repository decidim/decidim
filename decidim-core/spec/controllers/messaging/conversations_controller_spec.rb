# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Messaging::ConversationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: }
    let(:user1) { create(:user, organization:) }
    let(:user2) { create(:user, organization:) }
    let(:user3) { create(:user, organization:) }
    let(:user4) { create(:user, organization:) }
    let(:user5) { create(:user, organization:) }
    let(:user6) { create(:user, organization:) }
    let(:user7) { create(:user, organization:) }
    let(:user8) { create(:user, organization:) }
    let(:user9) { create(:user, organization:) }
    let(:user10) { create(:user, organization:) }

    let!(:conversation) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [create(:user)],
        body: "Hi!"
      )
    end

    let!(:conversation2) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [user1],
        body: "Hi!"
      )
    end

    let!(:conversation4) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [user1, user2, user3],
        body: "Hi to all three people!"
      )
    end

    let!(:conversation10) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [user1, user2, user3, user4, user5, user6, user7, user8, user9],
        body: "Hi to all six people!"
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

      context "when previous yet created conversation with 2 participant" do
        subject { get :new, params: { recipient_id: user1.id } }

        it "redirects to previous 2 participant created conversation" do
          expect(subject).to redirect_to conversation_path(conversation2)
        end
      end

      context "when previous yet created conversation 4 participants" do
        subject { get :new, params: { recipient_id: [user1.id, user2.id, user3.id] } }

        it "redirects to previous 4 participants created conversation" do
          expect(subject).to redirect_to conversation_path(conversation4)
        end
      end

      context "when previous yet created conversation 10 participants" do
        subject { get :new, params: { recipient_id: [user1.id, user2.id, user3.id, user4.id, user5.id, user6.id, user7.id, user8.id, user9.id] } }

        it "redirects to previous 10 participants created conversation" do
          expect(subject).to redirect_to conversation_path(conversation10)
        end
      end
    end

    describe "POST create" do
      context "when invalid" do
        render_views

        let(:max_length) { Decidim.config.maximum_conversation_message_length }

        it "redirects the user back" do
          post :create, format: :js, params: { recipient_id: 999, body: "" }

          expect(response.body).to include("Conversation not started. Try again later")
        end

        it "renders an error message" do
          post :create, format: :js, params: { recipient_id: user1.id, body: "A" * (max_length + 1) }

          expect(response.body).to include("Conversation not started. Try again later")
        end
      end
    end

    describe "PUT update" do
      context "when invalid" do
        render_views

        let(:max_length) { Decidim.config.maximum_conversation_message_length }

        it "renders an error message" do
          put :update, format: :js, params: { id: conversation.id, message: { body: "A" * (max_length + 1) } }

          expect(response.body).to include("Message was not sent due to an error")
        end
      end
    end
  end
end
