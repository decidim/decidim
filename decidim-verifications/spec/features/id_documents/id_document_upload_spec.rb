# frozen_string_literal: true

require "spec_helper"

describe "Identity document upload", type: :feature do
  let!(:organization) do
    create(:organization, available_authorizations: ["id_documents"])
  end

  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_id_documents.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Upload your identity document")
  end

  it "allows the user to upload her identity document" do
    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      file_name: "id.jpg"
    )

    expect(page).to have_content("Document uploaded successfully")
  end

  it "shows an error when upload failed" do
    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      file_name: "Exampledocument.pdf"
    )

    expect(page).to have_content("There was a problem uploading your document")
  end

  private

  def submit_upload_form(doc_type:, doc_number:, file_name:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    attach_file "Scanned copy of your document", Decidim::Dev.asset(file_name)

    click_button "Request verification"
  end
end
