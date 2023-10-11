# frozen_string_literal: true

require "spec_helper"

describe "Identity document request edition", type: :system do
  let(:organization) do
    create(
      :organization,
      available_authorizations: ["id_documents"],
      id_documents_methods: [:online]
    )
  end

  let(:verification_method) { :online }
  let!(:authorization) do
    create(
      :authorization,
      :pending,
      name: "id_documents",
      user:,
      verification_metadata: {
        "verification_type" => verification_method,
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX"
      },
      verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpeg")
    )
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_verifications.authorizations_path
    click_link "Identity documents"
  end

  context "when the organization only has online method active" do
    it "allows the user to change the data" do
      expect(page).to have_selector("form", text: "Request verification again")

      submit_upload_form(
        doc_type: "DNI",
        doc_number: "XXXXXXXY",
        file_name: "dni.jpg",
        remove_before: true
      )
      expect(page).to have_content("Document successfully reuploaded")
      authorization.reload
      expect(authorization.verification_metadata["verification_type"]).to eq "online"
      expect(authorization.verification_metadata["document_number"]).to eq "XXXXXXXY"
    end
  end

  context "when the organization only has offline method active" do
    let!(:organization) do
      create(
        :organization,
        available_authorizations: ["id_documents"],
        id_documents_methods: [:offline],
        id_documents_explanation_text: { en: "This is my explanation text" }
      )
    end
    let(:verification_method) { :offline }

    it "allows the user to change the data" do
      expect(page).to have_selector("form", text: "Request verification again")
      expect(page).not_to have_content("Scanned copy of your document")
      expect(page).to have_content("This is my explanation text")

      submit_upload_form(
        doc_type: "DNI",
        doc_number: "XXXXXXXY"
      )
      expect(page).to have_content("Document successfully reuploaded")
      authorization.reload
      expect(authorization.verification_metadata["verification_type"]).to eq "offline"
      expect(authorization.verification_metadata["document_number"]).to eq "XXXXXXXY"
    end
  end

  context "when the organization has both online and offline methods active" do
    let!(:organization) do
      create(
        :organization,
        available_authorizations: ["id_documents"],
        id_documents_methods: [:offline, :online],
        id_documents_explanation_text: { en: "This is my explanation text" }
      )
    end

    context "when the authorization is offline" do
      let(:verification_method) { :offline }

      it "allows the user to change the verification method" do
        expect(page).to have_selector("form", text: "Request verification again")
        expect(page).not_to have_content("Scanned copy of your document")
        click_link "Use online verification"

        submit_upload_form(
          doc_type: "DNI",
          doc_number: "XXXXXXXY",
          file_name: "dni.jpg",
          remove_before: true
        )

        expect(page).to have_content("Document successfully reuploaded")
        authorization.reload
        expect(authorization.verification_metadata["verification_type"]).to eq "online"
        expect(authorization.verification_metadata["document_number"]).to eq "XXXXXXXY"
        expect(authorization.verification_attachment).to be_present
      end
    end

    context "when the authorization is online" do
      let(:verification_method) { :online }

      it "allows the user to change the verification method" do
        expect(page).to have_selector("form", text: "Request verification again")
        click_link "Use offline verification"
        expect(page).not_to have_content("Scanned copy of your document")

        submit_upload_form(
          doc_type: "DNI",
          doc_number: "XXXXXXXY"
        )

        expect(page).to have_content("Document successfully reuploaded")
        authorization.reload
        expect(authorization.verification_metadata["verification_type"]).to eq "offline"
        expect(authorization.verification_metadata["document_number"]).to eq "XXXXXXXY"
        expect(authorization.verification_attachment).to be_present
      end
    end
  end

  private

  def submit_upload_form(doc_type:, doc_number:, file_name: nil, remove_before: false)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    options = { remove_before: }
    dynamically_attach_file(:id_document_upload_verification_attachment, Decidim::Dev.asset(file_name), options) if file_name

    click_button "Request verification again"
  end
end
