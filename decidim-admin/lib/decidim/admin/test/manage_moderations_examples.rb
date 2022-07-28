# frozen_string_literal: true

shared_examples "sorted moderations" do
  let!(:moderations) do
    reportables.first(reportables.length - 1).map do |reportable|
      moderation = create(:moderation, reportable:, report_count: 1, reported_content: reportable.reported_searchable_content_text)
      create(:report, moderation:)
      moderation
    end
  end
  let!(:moderation) { moderations.first }
  let(:moderations_link_text) { "Moderations" }

  before do
    visit participatory_space_path
    click_link moderations_link_text
  end

  it "sorts the most recent first" do
    link_text = find("ul[data-pages]").text.split("\n")[-2]
    within "ul[data-pages]" do
      click_link link_text
    end
    all("tbody tr").each_with_index do |row, _index|
      expect(row.find("td:first-child")).to have_content(reportables.first.id)
    end
  end
end

shared_examples "manage moderations" do
  let!(:moderations) do
    reportables.first(reportables.length - 1).map do |reportable|
      moderation = create(:moderation, reportable:, report_count: 1, reported_content: reportable.reported_searchable_content_text)
      create(:report, moderation:)
      moderation
    end
  end
  let!(:moderation) { moderations.first }
  let!(:hidden_moderations) do
    reportables.last(1).map do |reportable|
      moderation = create(:moderation, reportable:, report_count: 3, reported_content: reportable.reported_searchable_content_text, hidden_at: Time.current)
      create_list(:report, 3, moderation:, reason: :spam)
      moderation
    end
  end
  let(:moderations_link_text) { "Moderations" }

  before do
    visit participatory_space_path
    click_link moderations_link_text
  end

  context "when listing moderations" do
    it "only lists moderations for the current organization" do
      external_reportable = create :dummy_resource
      external_moderation = create(:moderation, reportable: external_reportable, report_count: 1, reported_content: external_reportable.reported_searchable_content_text)
      create(:report, moderation: external_moderation)

      visit current_path

      expect(page).to have_no_selector("tr[data-id=\"#{external_moderation.id}\"]")
    end

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

    it "user can sort by report count" do
      moderations.each_with_index { |moderation, index| moderation.update(report_count: index + 1) }
      moderations_ordered_by_report_count_asc = moderations.sort_by(&:report_count)

      within "table" do
        click_link "Count"

        all("tbody tr").each_with_index do |row, index|
          reportable_id = moderations_ordered_by_report_count_asc[index].reportable.id
          expect(row.find("td:first-child")).to have_content(reportable_id)
        end
      end
    end

    it "user can filter by reportable type" do
      reportable_type = moderation.reportable.class.name.demodulize
      within ".filters__section" do
        find(:xpath, "//a[contains(text(), 'Filter')]").hover
        find(:xpath, "//a[contains(text(), 'Type')]").hover
        click_link reportable_type
      end
      expect(page).to have_selector("tbody tr", count: moderations.length)
    end

    it "user can filter by reported content" do
      search = moderation.reportable.id
      within ".filters__section" do
        fill_in("Search Moderation by reportable id or content.", with: search)
        find(:xpath, "//button[@type='submit']").click
      end
      expect(page).to have_selector("tbody tr", count: 1)
    end

    it "user can see moderation details" do
      within "tr[data-id=\"#{moderation.id}\"]" do
        click_link "Expand"
      end

      reported_content_slice = moderation.reportable.reported_searchable_content_text.split("\n").first
      expect(page).to have_content(reported_content_slice)
    end

    context "when the reported content does not exist" do
      it "still renders the page" do
        moderation.reportable.destroy
        visit current_path

        expect(page).to have_no_selector("tr[data-id=\"#{moderation.id}\"]")
      end
    end
  end

  context "when listing hidden resources" do
    it "user can review them" do
      within ".card-title" do
        click_link "Hidden"
      end

      hidden_moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_css("a[href='#{moderation.reportable.reported_content_url}']")
        end
      end
    end
  end

  context "when listing comments for deleted resources" do
    let(:comments) do
      reportables.first(reportables.length - 1).map do |resource|
        create(:comment, commentable: resource)
      end
    end
    let!(:moderations) do
      comments.first(comments.length - 1).map do |reportable|
        space = reportable.is_a?(Decidim::Participable) ? reportable : reportable.participatory_space
        moderation = create(:moderation, reportable:, report_count: 1, participatory_space: space, reported_content: reportable.reported_searchable_content_text)
        create(:report, moderation:)

        reportable.root_commentable.destroy!
        reportable.reload

        moderation
      end
    end

    it "user can review them" do
      moderations.each do |moderation|
        within "tr[data-id=\"#{moderation.id}\"]" do
          expect(page).to have_content "Deleted resource"
          expect(page).to have_content "Spam"
        end
      end
    end
  end
end
