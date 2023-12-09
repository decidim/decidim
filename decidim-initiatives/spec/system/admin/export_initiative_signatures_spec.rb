# frozen_string_literal: true

require "spec_helper"

describe "Admin export initiatives' signature" do
  include_context "when admins initiative"

  let!(:votes) { create_list(:initiative_user_vote, 5, initiative:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "downloads the PDF file", :download do
    visit decidim_admin_initiatives.initiatives_path

    within find("tr", text: translated(initiative.title)) do
      page.find(".action-icon--edit").click
    end

    click_link "Export PDF of signatures"
    within "#confirm-modal-content" do
      click_button "OK"
    end

    expect(File.basename(download_path)).to include("votes_#{initiative.id}.pdf")
  end

  describe "`collect_user_extra_fields` settting" do
    before do
      visit decidim_admin_initiatives.export_pdf_signatures_initiative_path(initiative)
    end

    context "when it is disabled" do
      let(:initiative_type) { create(:initiatives_type, organization:) }

      it "does not show these columns in the PDF" do
        within all(".initiatives-votes-table")[1] do
          expect(page).not_to have_content "Name and surname"
          expect(page).not_to have_content "Document number"
          expect(page).not_to have_content "Date of birth"
        end
      end
    end

    context "when it is enabled" do
      let(:initiative_type) { create(:initiatives_type, :with_user_extra_fields_collection, organization:) }

      it "shows these columns in the PDF" do
        within all(".initiatives-votes-table")[1] do
          expect(page).to have_content "Name and surname"
          expect(page).to have_content "Document number"
          expect(page).to have_content "Date of birth"
        end
      end
    end
  end
end
