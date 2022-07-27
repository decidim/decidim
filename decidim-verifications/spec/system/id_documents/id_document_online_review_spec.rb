# frozen_string_literal: true

require "spec_helper"

describe "Identity document online review", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["id_documents"])
  end

  let(:user) { create(:user, :confirmed, organization:) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      id: 1,
      name: "id_documents",
      user:,
      verification_metadata: {
        "verification_type" => "online",
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX"
      },
      verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpeg")
    )
  end

  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_id_documents.root_path
    click_link "Verification #1"
  end

  it "allows the user to verify an identity document" do
    submit_verification_form(doc_type: "DNI", doc_number: "XXXXXXXX")

    expect(page).to have_content("Participant successfully verified")
    expect(page).to have_no_content("Verification #")
  end

  it "shows an error when information doesn't match" do
    submit_verification_form(doc_type: "NIE", doc_number: "XXXXXXXY")

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("Introduce the data in the picture")
  end

  context "when rejected" do
    before { click_link "Reject" }

    it "dismisses the verification from the list" do
      expect(page).to have_content("Verification rejected. Participant will be prompted to amend their documents")
      expect(page).to have_no_content("Verification #")
    end

    context "and the user logs back in" do
      before do
        relogin_as user, scope: :user
        visit decidim_verifications.authorizations_path
        click_link "Identity documents"
      end

      it "allows the user to change the uploaded documents" do
        expect(page).to have_selector("form", text: "Request verification again")
      end

      it "allows the verificator to review the amended request" do
        submit_reupload_form(
          doc_type: "DNI",
          doc_number: "XXXXXXXY",
          file_name: "dni.jpg"
        )
        expect(page).to have_content("Document successfully reuploaded")

        relogin_as admin, scope: :user
        visit decidim_admin_id_documents.root_path
        click_link "Verification #1"
        expect(page).to have_css("img[src*='dni.jpg']")
        submit_verification_form(doc_type: "DNI", doc_number: "XXXXXXXY")
        expect(page).to have_content("Participant successfully verified")
      end

      it "shows an informative message to the user" do
        expect(page).to have_content("There was a problem with your verification. Please try again")
        expect(page).to have_content("Make sure the information entered is correct")
        expect(page).to have_content("Make sure the information is clearly visible in the uploaded image")
      end
    end
  end

  private

  def submit_verification_form(doc_type:, doc_number:)
    select doc_type, from: "Type of the document"
    fill_in "Document number (with letter)", with: doc_number

    click_button "Verify"
  end

  def submit_reupload_form(doc_type:, doc_number:, file_name:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    dynamically_attach_file(:id_document_upload_verification_attachment, Decidim::Dev.asset(file_name))

    click_button "Request verification again"
  end
end
