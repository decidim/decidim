# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage reports" do
  before do
    visit decidim_admin.participatory_process_path(participatory_process)
    click_link "Reports"
  end

  context "listing reports" do
    it "user can review them" do
      click_link "Reported"

      reported_resources.each do |reportable|
        expect(page).to have_selector("tr", text: reportable.reported_content)
        expect(page).to have_selector("tr", text: reportable.reports.first.reason)
      end
    end

    it "user can un-report a resource" do
      click_link "Reported"

      within find("tr", text: reported_resources.first.reported_content) do
        click_link "Unreport"
      end

      within ".flash" do
        expect(page).to have_content("Resource successfully unreported")
      end
    end

    it "user can hide a resource" do
      click_link "Reported"

      within find("tr", text: reported_resources.first.reported_content) do
        click_link "Hide"
      end

      within ".flash" do
        expect(page).to have_content("Resource successfully hidden")
      end

      expect(page).to have_no_content(reported_resources.first.reported_content)
    end
  end

  context "listing hidden resources" do
    it "user can review them" do
      click_link "Hidden"

      hidden_resources.each do |reportable|
        expect(page).to have_selector("tr", text: reportable.reported_content)
      end
    end
  end
end
