# frozen_string_literal: true

require "spec_helper"

describe "Identity document offline review", type: :system do
  let!(:organization) do
    create(
      :organization,
      available_authorizations: ["id_documents"],
      id_documents_methods: ["offline"],
      id_documents_explanation_text: { en: "Foobar" }
    )
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
        "verification_type" => "offline",
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX"
      }
    )
  end

  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_id_documents.root_path
    click_link "Offline verification"
  end

  it "allows the user to verify an identity document" do
    submit_verification_form(doc_type: "DNI", doc_number: "XXXXXXXX")

    expect(page).to have_content("Participant successfully verified")
  end

  it "shows an error when there's no authorization for the given email" do
    submit_verification_form(doc_type: "DNI", doc_number: "XXXXXXXX", user_email: "this@doesnt.exist")

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("Introduce the participant email and the document data")
  end

  it "shows an error when information doesn't match" do
    submit_verification_form(doc_type: "NIE", doc_number: "XXXXXXXY")

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("Introduce the participant email and the document data")
  end

  private

  def submit_verification_form(doc_type:, doc_number:, user_email: user.email)
    fill_in "Participant email", with: user_email
    select doc_type, from: "Type of the document"
    fill_in "Document number (with letter)", with: doc_number

    click_button "Verify"
  end
end
