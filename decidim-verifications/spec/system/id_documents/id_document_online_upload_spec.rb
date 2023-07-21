# frozen_string_literal: true

require "spec_helper"

describe "Identity document online upload", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["id_documents"])
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_id_documents.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Upload your identity document")
  end

  it "allows the user to upload their identity document" do
    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      file_name: "id.jpg"
    )

    expect(page).to have_content("Document successfully uploaded")
  end

  it "does not allow to upload an invalid file" do
    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      file_name: "Exampledocument.pdf",
      keep_modal_open: true
    )

    expect(page).to have_content("Validation error!")
    expect(page).to have_css("button[disabled]", text: "Next")
  end

  private

  def submit_upload_form(doc_type:, doc_number:, file_name:, keep_modal_open: false)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    dynamically_attach_file(:id_document_upload_verification_attachment, Decidim::Dev.asset(file_name), front_interface: true, keep_modal_open:) if file_name

    click_button "Request verification" unless keep_modal_open
  end
end
