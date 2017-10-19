# frozen_string_literal: true

require "spec_helper"

describe "Identity document review", type: :feature do
  let!(:organization) do
    create(:organization, available_authorizations: ["id_documents"])
  end

  let(:user) { create(:user, :confirmed, organization: organization) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      id: 1,
      name: "id_documents",
      user: user,
      verification_metadata: {
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX"
      },
      verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpg")
    )
  end

  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_id_documents.root_path
    click_link "Verification #1"
  end

  it "allows the user to verify an identity document" do
    submit_verification_form(doc_type: "DNI", doc_number: "XXXXXXXX")

    expect(page).to have_content("User successfully verified")
    expect(page).to have_no_content("Verification #")
  end

  it "shows an error when information doesn't match" do
    submit_verification_form(doc_type: "NIE", doc_number: "XXXXXXXY")

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("INTRODUCE THE DATA IN THE PICTURE")
  end

  context "when rejected" do
    before { click_link "Reject" }

    it "dismisses the verification from the list" do
      expect(page).to have_content("Verification rejected. User will be prompted to amend her documents")
      expect(page).to have_no_content("Verification #")
    end

    context "and the user logs back in" do
      before do
        relogin_as user, scope: :user
        visit decidim.authorizations_path
        click_link "Identity documents"
      end

      it "allows the user to change the uploaded documents" do
        expect(page).to have_selector("form", text: "Request verification again")
        submit_reupload_form(doc_type: "NIE", doc_number: "XXXXXXXX", file_name: "id.jpg")
        expect(page).to have_content("Document reuploaded successfully")
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
    attach_file "Scanned copy of your document", Decidim::Dev.asset(file_name)

    click_button "Request verification again"
  end
end
