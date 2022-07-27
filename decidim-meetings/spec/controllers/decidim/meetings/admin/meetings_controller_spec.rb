# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingsController, type: :controller do
  routes { Decidim::Meetings::AdminEngine.routes }

  let(:meeting) { create :meeting, component: meeting_component }
  let(:user) { create :user, :admin, :confirmed, organization: }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone:) }
  let(:participatory_process) { create :participatory_process, organization: }
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
end
