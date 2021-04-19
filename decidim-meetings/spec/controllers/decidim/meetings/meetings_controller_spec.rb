# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingsController, type: :controller do
  routes { Decidim::Meetings::Engine.routes }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:meeting) { create :meeting, component: meeting_component }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
  end

  shared_examples "having meeting access visibility applied" do
    it "can access non private meetings" do
      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end

    it "can access private but transparent meetings" do
      meeting.update(private_meeting: true, transparent: true)

      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end

    it "can access private and non transparent meetings" do
      meeting.update(private_meeting: true, transparent: false)

      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end
  end

  describe "#show" do
    context "when user is not logged in" do
      it "can access non private meetings" do
        get :show, params: { id: meeting.id }

        expect(subject).to render_template(:show)
        expect(flash[:alert]).to be_blank
      end

      it "can access private but transparent meetings" do
        meeting.update(private_meeting: true, transparent: true)

        get :show, params: { id: meeting.id }

        expect(subject).to render_template(:show)
        expect(flash[:alert]).to be_blank
      end

      it "can NOT access private and non transparent meetings" do
        meeting.update(private_meeting: true, transparent: false)

        get :show, params: { id: meeting.id }

        expect(subject).to redirect_to(Decidim::ResourceLocatorPresenter.new(meeting).index)
        expect(flash[:alert]).not_to be_empty
      end
    end

    context "with signed in user" do
      before { sign_in user }

      context "when user is admin" do
        let!(:user) { create :user, :admin, :confirmed, organization: organization }

        it_behaves_like "having meeting access visibility applied"
      end

      context "when user is process admin" do
        let!(:user) { create :user, :confirmed, organization: organization }
        let!(:participatory_process_user_role) { create :participatory_process_user_role, user: user, participatory_process: participatory_process }

        it_behaves_like "having meeting access visibility applied"
      end

      context "when user is private user" do
        let!(:user) { create :user, :confirmed, organization: organization }
        let!(:participatory_space_private_user) { create :participatory_space_private_user, user: user, privatable_to: participatory_process }

        it_behaves_like "having meeting access visibility applied"
      end

      context "when user has registered to the meeting" do
        let!(:user) { create :user, :confirmed, organization: organization }
        let!(:registration) { create :registration, user: user, meeting: meeting }

        it_behaves_like "having meeting access visibility applied"
      end
    end
  end
end
