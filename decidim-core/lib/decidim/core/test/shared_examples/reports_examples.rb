# frozen_string_literal: true

shared_examples "logged in user reports content" do
  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and the user has not reported the resource yet" do
      it "reports the resource" do
        visit reportable_path

        expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
        find(%(button[data-dialog-open="flagModal"])).click
        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end
  end
end

shared_examples "higher user role reports" do
  include_examples "logged in user reports content"
end

shared_examples "higher user role hides" do
  context "and the admin hides the resource" do
    before do
      login_as user, scope: :user
    end

    it "reports the resource" do
      visit reportable_path

      expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
      find(%(button[data-dialog-open="flagModal"])).click
      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        find(:css, "input[name='report[hide]']").set(true)
        click_on "Hide"
      end

      sleep(1)

      expect(page).to have_current_path(reportable_index_path, ignore_query: true)

      expect(reportable.reload).to be_hidden
    end
  end
end

shared_examples "higher user role hides resource with comments" do
  context "and the admin hides a resource with comments" do
    let!(:comments) { create_list(:comment, 2, body: "Dummy comment", commentable: reportable, author: user) }

    before do
      login_as user, scope: :user
      Decidim::Ai::SpamDetection.create_reporting_user!
    end

    it "hides the resource" do
      visit decidim.search_path
      expect(page).to have_content(translated(comments.first.body))
      expect(page).to have_content(translated(comments.second.body))

      visit reportable_path

      expect(page).to have_content(translated(comments.first.body))
      expect(page).to have_content(translated(comments.second.body))

      expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
      find(%(button[data-dialog-open="flagModal"])).click
      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        find(:css, "input[name='report[hide]']").set(true)
        click_button "Hide"
      end

      sleep(1)

      expect(page).to have_current_path(reportable_index_path, ignore_query: true)

      perform_enqueued_jobs

      expect(reportable.reload).to be_hidden
      expect(comments.first.reload).to be_hidden
      expect(comments.second.reload).to be_hidden

      visit decidim.search_path
      expect(page).not_to have_content(translated(comments.first.body))
      expect(page).not_to have_content(translated(comments.second.body))
    end
  end
end

shared_examples "higher user role does not have hide" do
  context "and the admin reports" do
    before do
      login_as user, scope: :user
    end

    it "reports the resource" do
      visit reportable_path

      expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
      find(%(button[data-dialog-open="flagModal"])).click
      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        expect(page).not_to have_field(name: "report[hide]")
      end
    end
  end
end

shared_examples "reports" do
  context "when the user is not logged in" do
    it "gives the option to sign in" do
      visit reportable_path

      expect(page).not_to have_css("html.is-disabled")

      click_button "Report"

      expect(page).to have_css("html.is-disabled")
    end
  end

  include_examples "logged in user reports content"

  context "and the user has reported the resource previously" do
    before do
      moderation = create(:moderation, reportable:, participatory_space: participatory_process)
      create(:report, moderation:, user:, reason: "spam")
      login_as user, scope: :user
    end

    it "cannot report it twice" do
      visit reportable_path

      expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
      find(%(button[data-dialog-open="flagModal"])).click
      expect(page).to have_css(".flag-modal", visible: :visible)

      expect(page).to have_content "already reported"
    end
  end
end
shared_examples "reports by user type" do
  context "when reporting user is regular visitor" do
    include_examples "reports"
  end

  context "When reporting user is platform admin" do
    let!(:user) { create(:user, :admin, :confirmed, organization:) }
    include_examples "higher user role reports"
    include_examples "higher user role hides"
  end
  context "When reporting user is process admin" do
    let!(:user) { create :process_admin, :confirmed, participatory_process: }

    include_examples "higher user role reports"
    include_examples "higher user role hides"
  end
  context "When reporting user is process collaborator" do
    let!(:user) { create :process_collaborator, :confirmed, participatory_process: }
    include_examples "higher user role reports"
    include_examples "higher user role does not have hide"
  end
  context "When reporting user is process moderator" do
    let!(:user) { create :process_moderator, :confirmed, participatory_process: }
    include_examples "higher user role reports"
    include_examples "higher user role hides"
  end
  context "When reporting user is process valuator" do
    let!(:user) { create :process_valuator, :confirmed, participatory_process: }
    include_examples "higher user role reports"
    include_examples "higher user role does not have hide"
  end
end
