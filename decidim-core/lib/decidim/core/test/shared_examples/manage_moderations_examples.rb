# frozen_string_literal: true

shared_examples "manage moderations" do
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
      create_list(:report, 3, moderation: moderation, reason: :spam)
      moderation
    end
  end

  before do
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Moderations"
  end

  context "listing moderations" do
    it "user can review them" do
      moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_css("a[href='#{moderation.reportable.reported_content_url}']")
          expect(page).to have_content "Spam"
        end
      end
    end

    it "user can un-report a resource" do
      within "tr[data-id=\"#{moderation.id}\"]" do
        click_link "Unreport"
      end

      expect(page).to have_admin_callout("Resource successfully unreported")
    end

    it "user can hide a resource" do
      within "tr[data-id=\"#{moderation.id}\"]" do
        click_link "Hide"
      end

      expect(page).to have_admin_callout("Resource successfully hidden")
      expect(page).to have_no_content(moderation.reportable.reported_content_url)
    end
  end

  context "listing hidden resources" do
    it "user can review them" do
      click_link "Hidden"

      hidden_moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_css("a[href='#{moderation.reportable.reported_content_url}']")
        end
      end
    end
  end
end
