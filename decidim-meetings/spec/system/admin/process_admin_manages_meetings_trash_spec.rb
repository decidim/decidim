# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages meetings trash" do
  let(:manifest_name) { "meetings" }
  let(:admin_resource_path) { current_path }
  let(:trash_path) { Decidim::EngineRouter.admin_proxy(current_component).manage_trash_meetings_path }
  let(:title) { { en: "My official meeting" } }
  let!(:resource) { create(:meeting, :official, component: current_component, title:, deleted_at:) }
  let(:deleted_at) { nil }
  let(:resource_row) { "tr[data-id='#{resource.id}']" }

  include_context "when managing a component as a process admin"

  it "shows the move to trash action enabled" do
    within resource_row do
      find("button[data-controller='dropdown']").click

      expect(page).to have_link("Move to trash")
      expect(page).to have_no_css(".dropdown__button-disabled", text: "Move to trash")
    end
  end

  it "shows the link to the deleted meetings" do
    expect(page).to have_link("View deleted meetings", href: trash_path)
  end

  it_behaves_like "manage soft deletable resource", "meeting"
  it_behaves_like "manage trashed resource", "meeting"

  context "when the user is a process collaborator" do
    let(:user) { create(:process_collaborator, :confirmed, organization:, participatory_process:) }

    it "does not allow to move the meeting to the trash" do
      within resource_row do
        find("button[data-controller='dropdown']").click

        expect(page).to have_no_link("Move to trash")
        expect(page).to have_css(".dropdown__button-disabled", text: "Move to trash")
      end
    end

    it "does not blame a participant for an official meeting" do
      within resource_row do
        expect(page).to have_no_css("[data-tooltip-tooltip-value*='Cannot delete this meeting']", visible: :all)
      end
    end

    context "when the meeting is created by a participant" do
      let!(:resource) { create(:meeting, :not_official, component: current_component, title:) }

      it "does not blame the participant for the missing permission" do
        within resource_row do
          expect(page).to have_css(".dropdown__button-disabled", text: "Move to trash", visible: :all)
          expect(page).to have_no_css("[data-tooltip-tooltip-value*='Cannot delete this meeting']", visible: :all)
        end
      end
    end

    it "does not show the link to the deleted meetings" do
      expect(page).to have_no_link("View deleted meetings")
    end
  end
end
