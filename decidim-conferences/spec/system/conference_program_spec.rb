# frozen_string_literal: true

require "spec_helper"

describe "Conference program", type: :system do
  include Decidim::TranslationsHelper
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }
  let!(:component) do
    create(:component, manifest_name: :meetings, participatory_space: conference)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no meetings and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_conference_program_path(conference, component) }
    end
  end

  context "when there are no meeting and accessing from the conference homepage" do
    it "the menu link is not shown" do
      visit decidim_conferences.conference_path(conference)

      within ".process-nav" do
        expect(page).to have_no_content(translated_attribute(component.name))
      end
    end
  end

  context "when the conference does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_conference_program_path(conference_slug: 999_999_999, id: component.id) }
    end
  end

  context "when there are some conference meetings" do
    let!(:conference_speakers) { create_list(:conference_speaker, 3, :with_meeting, conference:, meetings_component: component) }
    let(:meetings) { Decidim::ConferenceMeeting.where(component:) }

    before do
      visit decidim_conferences.conference_conference_program_path(conference, component)
    end

    context "and accessing from the conference homepage" do
      it "the menu link is shown" do
        visit decidim_conferences.conference_path(conference)

        within ".process-nav" do
          expect(page).to have_content(translated_attribute(component.name).upcase)
          click_link translated_attribute(component.name)
        end

        expect(page).to have_current_path decidim_conferences.conference_conference_program_path(conference, component)
      end
    end

    it "lists all conference meetings" do
      within ".programme-day" do
        expect(page).to have_selector(".programme-title", count: 3)

        meetings.each do |meeting|
          expect(page).to have_content(Decidim::ConferenceMeetingPresenter.new(meeting).title)
        end
      end
    end
  end
end
