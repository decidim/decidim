# frozen_string_literal: true

require "spec_helper"

describe "Identity document offline request", type: :system do
  let!(:organization) do
    create(
      :organization,
      available_authorizations: ["id_documents"],
      id_documents_methods: [:offline],
      id_documents_explanation_text: { en: "This is my explanation text" }
    )
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_id_documents.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Upload your identity document")
    expect(page).to have_content("This is my explanation text")
  end

  it "allows the user fill in their identity document" do
    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX"
    )

    expect(page).to have_content("Document successfully uploaded")
  end

  private

  def submit_upload_form(doc_type:, doc_number:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number

    click_button "Request verification"
  end
end
