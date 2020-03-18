# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Messaging::ConversationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:user1) { create(:user, organization: organization) }
    let(:user2) { create(:user, organization: organization) }
    let(:user3) { create(:user, organization: organization) }
    let(:user4) { create(:user, organization: organization) }
    let(:user5) { create(:user, organization: organization) }
    let(:user6) { create(:user, organization: organization) }

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

    # ********

    describe "GET conversations", type: :feature do
      context "when one participants conversation" do
        let(:conversation1) do
          Messaging::Conversation.start!(
            originator: user,
            interlocutors: [:user1],
            body: "Hi!"
          )
        end
        # before do
        #   request.env["decidim.current_organization"] = organization
        #   sign_in user
        # end
        # subject { get :index }
        # subject { get "/users/#{user.id}" }
        # subject { get "index" }

        it "one participant conversation. Shows only one participant name" do
          # byebug
          request.env["decidim.current_organization"] = organization
          sign_in user
          visit conversations_url
          # expect(response).to have_content(user1.name)
          expect(page).to have_content(user1.name)
        end
      end
    end

    describe "GET conversations" do
      context "when three participants conversation" do
        subject { get :index }

        let(:conversation3) do
          Messaging::Conversation.start!(
            originator: user,
            interlocutors: [:user1, :user2, :user3],
            body: "Hi to all three people!"
          )
        end

        it "one participant conversation. Shows only one participant name" do
          expect(subject).to have_content([user1.name, user2.name, user3.name])
        end
      end
    end

    describe "GET conversations" do
      context "when six participants conversation" do
        subject { get :index }

        let(:conversation6) do
          Messaging::Conversation.start!(
            originator: user,
            interlocutors: [:user1, :user2, :user3, :user4, :user5, :user6],
            body: "Hi to all six people!"
          )
        end

        it "one participant conversation. Shows only one participant name" do
          expect(subject).to have_content([user1.name, user2.name, user3.name])
          expect(subject).not_to have_content([user4.name, user5.name, user6.name])
        end
      end
    end

    # ********

    describe "GET new" do
      context "when only one participant" do
        subject { get :new, params: { recipient_id: user1.id } }

        it "shows start conversation page with one participant name in title" do
          expect(subject).to have_content(user1.name)
        end

        it "doesnt show current user name in conversation title" do
          expect(subject).not_to have_content(user.name)
        end
      end
    end

    describe "GET new" do
      context "when only two more participants and one is current user " do
        subject { get :new, params: { recipient_id: [user.id, user1.id] } }

        it "shows start conversation page with only the other participant name in title" do
          expect(subject).to have_content(user1.name)
          expect(subject).not_to have_content(user.name)
        end
      end
    end

    describe "GET new" do
      context "when six participants" do
        subject { get :new, params: { recipient_id: [user1.id, user2.id, user3.id, user4.id, user5.id, user6.id] } }

        it "shows start conversation page with all their six names in title" do
          expect(subject).to have_content(
            [
              user1.name, user2.name, user3.name, user4.name, user5.name, user6.name
            ]
          )
          expect(subject).not_to have_content(user.name)
        end
      end
    end

    describe "GET new" do
      context "when another participant previous created conversation" do
        subject { get :new, params: { recipient_id: user1.id } }

        it "redirects to previous one participant created conversation" do
          conversation = controller.helpers.conversation_between(user, user1)
          expect(subject).to redirect_to conversation_path(conversation)
        end
      end
    end

    describe "GET new" do
      context "when six participants previous created conversation" do
        subject { get :new, params: { recipient_id: [user1.id, user2.id, user3.id, user4.id, user5.id, user6.id] } }

        it "redirects to previous created six participants conversation" do
          participants = [user, user1, user2, user3, user4, user5, user6]
          conversation = controller.helpers.conversation_between_multiple(participants)
          expect(subject).to redirect_to conversation_path(conversation)
        end
      end
    end

    # -----------

    describe "POST create" do
      context "when three participants" do
        it "creates conversation with all three participants plus current_user" do
        end
      end
    end

    describe "POST create" do
      context "when three participants" do
        it "creates conversation with all three participants plus current_user" do
        end
      end
    end

    describe "POST create" do
      context "when more than 9 participants" do
        it "shows invalid conversation message" do
        end
      end
    end
  end
end
