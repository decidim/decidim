# frozen_string_literal: true

require "spec_helper"

describe "DownloadYourData" do
  let!(:public_resource) { create(:dummy_resource, :published, author: user) }

  let(:user) { create(:user, :confirmed, name: "Hodor User") }
  let(:organization) { user.organization }
  let!(:expired_export) do
    export = Decidim::DownloadYourDataExporter.new(user, "download_your_data", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export
    export.expires_at = 2.weeks.ago
    export.save!
    export.reload
  end
  let!(:active_export) { Decidim::DownloadYourDataExporter.new(user, "download_your_data", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export }
  let(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user_public_resource) { create(:dummy_resource, :published, author: other_user) }

  let!(:other_user_expired_export) do
    export = Decidim::DownloadYourDataExporter.new(other_user, "download_your_data", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export
    export.expires_at = 2.weeks.ago
    export.save!
    export.reload
  end

  let!(:other_user_active_export) do
    Decidim::DownloadYourDataExporter.new(other_user, "download_your_data", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export
  end

  around do |example|
    previous = Capybara.raise_server_errors

    Capybara.raise_server_errors = false
    example.run
    Capybara.raise_server_errors = previous
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples_for "downloading data" do
    before do
      visit decidim.download_your_data_path
    end

    describe "show button export data" do
      it "export the user's data" do
        within ".download-your-data" do
          expect(page).to have_content("Here you can find all the downloads available for you")
          expect(page).to have_content("You can request a .zip file with your submissions and personal data.")
        end
      end

      it "displays only links from current_user" do
        expect(page).to have_css("form[action=\"#{decidim.download_download_your_data_path(expired_export)}\"]")
        within "form[action=\"#{decidim.download_download_your_data_path(expired_export)}\"]" do
          expect(page).to have_button("Download", disabled: true)
        end
        expect(page).to have_css("form[action=\"#{decidim.download_download_your_data_path(active_export)}\"]")
        within "form[action=\"#{decidim.download_download_your_data_path(active_export)}\"]" do
          expect(page).to have_button("Download", disabled: false)
        end
        expect(page).to have_no_css("form[action=\"#{decidim.download_download_your_data_path(other_user_expired_export)}\"]")
        expect(page).to have_no_css("form[action=\"#{decidim.download_download_your_data_path(other_user_active_export)}\"]")
      end
    end

    describe "downloading attachments" do
      it "when requesting the file of other user's data" do
        visit decidim.download_download_your_data_path(other_user_active_export)

        expect(page).to have_content(ActiveRecord::RecordNotFound)
      end

      it "when requesting the expired file of other user's data" do
        visit decidim.download_download_your_data_path(other_user_expired_export)

        expect(page).to have_content(ActiveRecord::RecordNotFound)
      end

      it "when requesting my own expired file" do
        visit decidim.download_download_your_data_path(expired_export)

        expect(page).to have_content("The export has expired. Try to generate a new export.")
      end

      it "when requesting my own active file", :slow, download: true do
        expect(active_export.file).to be_attached
        expect(downloads.length).to eq(0)

        visit decidim.download_download_your_data_path(active_export)
        wait_for_download

        expect(downloads.length).to eq(1)
        expect(download).to match(/.*\.zip/)
      end
    end

    describe "Export data" do
      it "exports an archive with all user information" do
        expect(Decidim::PrivateExport.count).to eq(4)
        perform_enqueued_jobs { click_on "Request" }

        within_flash_messages do
          expect(page).to have_content("data is currently in progress")
        end
        expect(Decidim::PrivateExport.count).to eq(5)

        expect(last_email.subject).to include("Hodor User")
      end
    end
  end

  context "when user has not yet accepted tos" do
    let(:user) { create(:user, :confirmed, name: "Hodor User", accepted_tos_version: nil) }

    include_examples "downloading data"
  end

  context "when on the download your data page" do
    include_examples "downloading data"
  end
end
