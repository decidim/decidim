# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserConversationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: }
    let(:another_user) { create :user, :confirmed, organization: }
    let(:user_group) { create :user_group, :confirmed, organization:, users: [user, another_user] }
    let(:another_group) { create :user_group, :confirmed, organization:, users: [another_user] }
    let!(:another_group_member) { create(:user_group_membership, user:, user_group: another_group, role: :member) }
    let(:external_user) { create :user, :confirmed, organization: }

    let(:conversation) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [user_group],
        body: "Hi from user!"
      )
      Messaging::Conversation.start!(
        originator: user_group,
        interlocutors: [create(:user)],
        body: "Hi from group!"
      )
    end

    let(:profile) { user_group }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "GET index" do
      context "when profile is a user" do
        subject { get :index, params: { nickname: user.nickname } }

        it "redirects to user conversations controller" do
          expect(subject).to redirect_to conversations_path
        end
      end

      context "when profile is a group" do
        subject { get :index, params: { nickname: profile.nickname } }

        context "and logged user can admin the group" do
          it "renders the message list" do
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
          end
        end

        it "non-admins cannot view conversations" do
          expect do
            get :index, params: { nickname: another_group.nickname }
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end

    describe "GET new" do
      context "when is the same user" do
        subject { get :new, params: { nickname: profile.nickname, recipient_id: profile.id } }

        it "redirects to the profile path" do
          expect(subject).to redirect_to profile_path(profile.nickname)
        end
      end

      context "when previous yet created conversation with 2 participant" do
        subject { get :new, params: { nickname: profile.nickname, recipient_id: another_group.id } }

        let!(:conversation) do
          Messaging::Conversation.start!(
            originator: profile,
            interlocutors: [another_group],
            body: "Hi!"
          )
        end

        it "redirects to previous 2 participant created conversation" do
          expect(subject).to redirect_to profile_conversation_path(nickname: profile.nickname, id: conversation)
        end
      end

      context "when previous yet created conversation with multiple participants" do
        subject { get :new, params: { nickname: profile.nickname, recipient_id: [external_user.id, another_group.id] } }

        let!(:conversation) do
          Messaging::Conversation.start!(
            originator: profile,
            interlocutors: [external_user, another_group],
            body: "Hi!"
          )
        end

        it "redirects to previous 2 participant created conversation" do
          expect(subject).to redirect_to profile_conversation_path(nickname: profile.nickname, id: conversation.id)
        end
      end
    end

    describe "POST create" do
      context "when invalid" do
        let(:params) do
          { nickname: profile.nickname, recipient_id: 999, body: "" }
        end

        it "does not create a conversation" do
          expect do
            post :create, params:
          end.not_to change(Messaging::Conversation, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:ok)
        end
      end

      context "when group creates a conversation" do
        let(:params) do
          { nickname: profile.nickname, recipient_id: [external_user.id, another_group.id], body: "Hi!" }
        end

        it "does not create a conversation" do
          expect do
            post :create, params:
          end.to change(Messaging::Conversation, :count).by(1)

          expect(flash[:alert]).to be_nil
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to profile_conversations_path(nickname: profile.nickname)
        end

        context "and conversation already exists" do
          let!(:conversation) do
            Messaging::Conversation.start!(
              originator: profile,
              interlocutors: [external_user, another_group],
              body: "Hi!"
            )
          end

          it "does not create a conversation" do
            expect do
              post :create, params:
            end.not_to change(Messaging::Conversation, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
            expect(subject).to redirect_to profile_conversation_path(nickname: profile.nickname, id: conversation.id)
          end
        end
      end
    end

    describe "PUT update" do
      let!(:conversation) do
        Messaging::Conversation.start!(
          originator: profile,
          interlocutors: [external_user, another_group],
          body: "Hi!"
        )
      end

      context "when invalid" do
        it "renders an error message" do
          put :update, format: :js, params: { nickname: profile.nickname, id: conversation.id, message: { body: "" } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:update)
        end
      end

      context "when valid" do
        it "renders the message" do
          put :update, format: :js, params: { nickname: profile.nickname, id: conversation.id, message: { body: "Moby Dick" } }

          expect(response).to have_http_status(:ok)
          expect(response).to render_template(:update)
        end
      end
    end
  end
end
