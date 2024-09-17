# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingsController do
  routes { Decidim::Meetings::AdminEngine.routes }

  let(:meeting) { create(:meeting, component: meeting_component) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:proposal) { create(:proposal, component: proposal_component) }
  let(:meeting_proposals) { meeting.authored_proposals }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
    sign_in user
  end

  describe "#destroy" do
    before do
      proposal.coauthorships.clear
      proposal.add_coauthor(meeting)
    end

    context "when having at least one proposal (invalid)" do
      it "flashes an alert message" do
        delete :destroy, params: { id: meeting.id }

        expect(flash[:alert]).not_to be_empty
      end

      it "renders the index view" do
        delete :destroy, params: { id: meeting.id }

        expect(subject).to render_template(:index)
      end
    end
  end

  describe "PATCH #soft_delete" do
    it "soft deletes the meeting" do
      expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(meeting, user).and_call_original

      patch :soft_delete, params: { id: meeting.id }

      expect(response).to redirect_to(meetings_path)
      expect(flash[:notice]).to eq(I18n.t("meetings.soft_delete.success", scope: "decidim.meetings.admin"))
      expect(meeting.reload.deleted_at).not_to be_nil
    end
  end

  describe "PATCH #restore" do
    before do
      meeting.update!(deleted_at: Time.current)
    end

    it "restores the meeting" do
      expect(Decidim::Commands::RestoreResource).to receive(:call).with(meeting, user).and_call_original

      patch :restore, params: { id: meeting.id }

      expect(response).to redirect_to(deleted_meetings_path)
      expect(flash[:notice]).to eq(I18n.t("meetings.restore.success", scope: "decidim.meetings.admin"))
      expect(meeting.reload.deleted_at).to be_nil
    end
  end

  describe "GET #deleted" do
    let!(:deleted_meeting) { create(:meeting, component: meeting_component, deleted_at: Time.current) }
    let!(:active_meeting) { create(:meeting, component: meeting_component) }

    it "lists only deleted meetings" do
      get :deleted

      expect(response).to have_http_status(:ok)
      expect(controller.view_context.deleted_meetings).to include(deleted_meeting)
      expect(controller.view_context.deleted_meetings).not_to include(active_meeting)
    end

    it "renders the deleted template" do
      get :deleted

      expect(response).to render_template(:deleted)
    end
  end
end
