# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserConversationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:another_user) { create :user, :confirmed, organization: organization }
    let(:user_group) { create :user_group, :confirmed, organization: organization, users: [user, another_user] }
    let(:another_group) { create :user_group, :confirmed, organization: organization, users: [another_user] }
    let!(:another_group_member) { create(:user_group_membership, user: user, user_group: another_group, role: :member) }

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

    # describe "GET new" do
    #   context "when is the same user" do
    #     subject { get :new, params: { recipient_id: user.id } }

    #     it "redirects to the profile path" do
    #       expect(subject).to redirect_to profile_path(user.nickname)
    #     end
    #   end
    # end

    # describe "POST create" do
    #   context "when invalid" do
    #     it "redirects the user back" do
    #       post :create, params: { recipient_id: 999, body: "" }

    #       expect(response).to redirect_to("/")
    #     end
    #   end
    # end

    # describe "PUT update" do
    #   context "when invalid" do
    #     it "renders an error message" do
    #       put :update, format: :js, params: { id: conversation.id, message: { body: "A" * 1001 } }

    #       expect(response.body).to include("Message not sent")
    #     end
    #   end
    # end
  end
end
