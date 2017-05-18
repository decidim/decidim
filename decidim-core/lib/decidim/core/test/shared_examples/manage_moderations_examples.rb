# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage moderations" do
  let!(:moderations) do
    reportables.first(reportables.length - 1).map do |reportable|
      moderation = create(:moderation, reportable: reportable, report_count: 1)
      create(:report, moderation: moderation)
      moderation
    end
  end
  let!(:moderation) { moderations.first }
  let!(:hidden_moderations) do
    reportables.last(1).map do |reportable|
      moderation = create(:moderation, reportable: reportable, report_count: 3, hidden_at: Time.current)
      create_list(:report, 3, moderation: moderation)
      moderation
    end
  end

  before do
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Moderations"
  end

  context "listing moderations" do
    it "user can review them" do
      click_link "Moderations"

      moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_content moderation.reportable.reported_content
          expect(page).to have_content moderation.reports.first.reason
        end
      end
    end

    it "user can un-report a resource" do
      click_link "Moderations"

      within "tr[data-id=\"#{moderation.id}\"]" do
        find("a.action-icon--unreport").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Resource successfully unreported")
      end
    end

    it "user can hide a resource" do
      click_link "Moderations"

      within "tr[data-id=\"#{moderation.id}\"]" do
        find("a.action-icon--hide").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Resource successfully hidden")
      end

      expect(page).to have_no_content(moderation.reportable.reported_content)
    end
  end

  context "listing hidden resources" do
    it "user can review them" do
      click_link "Hidden"

      hidden_moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_content moderation.reportable.reported_content
        end
      end
    end
  end
end
