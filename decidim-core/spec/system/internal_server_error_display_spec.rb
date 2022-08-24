# frozen_string_literal: true

require "spec_helper"

describe "Internal server error display", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, name: "Sarah Kerrigan", organization:) }

  before do
    switch_to_host(organization.host)
    allow(Time).to receive(:current).and_return("01/01/2022 - 12:00".to_time)
    visit "/500"
  end

  it "generates the copiable form" do
    expect(page).to have_content("Please try again later. If the error persists, please copy the following info and send it to info@decidim.org along with other information you may provide")
    expect(page).to have_content("User ID:\nUnknown")
    expect(page).to have_button("Copy to clipboard")
    expect(page).to have_content("01/01/2022 - 12:00")
  end

  describe "#reference_id" do
    let(:reference_id) { "ee3406bc-7602-4cbe-8807-37808f7f9ed8" }

    before do
      allow(Rails.logger).to receive(:error).at_least(:once)
      allow(SecureRandom).to receive(:uuid).and_return(reference_id)
      visit current_path
    end

    it "Adds UUid to the log file" do
      expect(page).to have_content("Reference:\n#{reference_id}")
      expect(Rails.logger).to have_received(:error).with(reference_id).once
    end
  end

  context "with log in as a user" do
    before do
      login_as user, scope: :user
      visit current_path
    end

    it "displays the user ID" do
      expect(page).to have_content("User ID:\n#{user.id}")
    end

    context "when clicking copy link button" do
      before do
        click_on "Copy to clipboard"
      end

      it "copies the data to the clipboard" do
        within "#input-text" do
          expect(page).to have_content("Text copied!")
        end
      end
    end
  end
end
