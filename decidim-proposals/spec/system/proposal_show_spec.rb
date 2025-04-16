# frozen_string_literal: true

require "spec_helper"

describe "Show a Proposal" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component:) }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  describe "proposal show" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { resource_locator(proposal).path }
    end

    context "when requesting the proposal path" do
      before do
        visit_proposal
        expect(page).to have_content(translated(proposal.title))
      end

      it_behaves_like "share link"

      describe "extra admin link" do
        before do
          login_as user, scope: :user
          visit current_path
        end

        context "when I am an admin user" do
          let!(:user) { create(:user, :admin, :confirmed, organization:) }

          it "has a link to answer to the proposal at the admin" do
            within "header" do
              expect(page).to have_css("#admin-bar")
              expect(page).to have_link("Answer", href: /.*admin.*proposal-answer.*/)
            end
          end
        end

        context "when I am a regular user" do
          let!(:user) { create(:user, :confirmed, organization:) }

          it "does not have a link to answer the proposal at the admin" do
            within "header" do
              expect(page).to have_no_css("#admin-bar")
              expect(page).to have_no_link("Answer")
            end
          end
        end
      end
    end

    context "when proposal author is a meeting" do
      let(:address) { "Somewhere over the rainbow" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let!(:author) { create(:user, :deleted, organization: component.organization) }
      let!(:proposal) { create(:proposal, component:, users: [author]) }
      let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
      let!(:meeting) { create(:meeting, :published, component: meeting_component, address:, latitude:, longitude:) }

      it "shows the meeting link" do
        stub_geocoding_coordinates([latitude, longitude])
        proposal.link_resources(meeting, "proposals_from_meeting")
        visit resource_locator(meeting).path
        expect(page).to have_content(translated(proposal.title))
      end

      context "when the proposal component has votes enabled" do
        let(:component) { create(:proposal_component, :with_votes_enabled, participatory_space: participatory_process) }

        it "shows the meeting link" do
          stub_geocoding_coordinates([latitude, longitude])
          proposal.link_resources(meeting, "proposals_from_meeting")
          visit resource_locator(meeting).path
          expect(page).to have_content(translated(proposal.title))
        end
      end
    end
  end
end
