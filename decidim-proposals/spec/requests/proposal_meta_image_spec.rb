# frozen_string_literal: true

require "spec_helper"

describe "Proposal meta image" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:author) { create(:user, :confirmed, organization:) }
  let!(:proposal) do
    create(
      :proposal,
      component:,
      users: [author],
      body: { en: "<p>Proposal body text</p><p><img src=\"#{image_src}\"></p>" }
    )
  end
  let(:request_path) { Decidim::EngineRouter.main_proxy(component).proposal_path(proposal) }
  let(:headers) { { "HOST" => organization.host } }

  def og_image
    response.parsed_body.at_css("meta[property='og:image']")&.[]("content").to_s
  end

  before do
    get request_path, headers:
  end

  context "when the body references an editor image from the organization" do
    let(:editor_image) { create(:editor_image, organization:, author:) }
    let(:image_src) { editor_image.file.blob.to_global_id.to_s }

    it "uses the image for og:image" do
      expect(response).to have_http_status(:ok)
      expect(og_image).to include(editor_image.file.blob.signed_id)
    end
  end

  context "when the body references a foreign blob by its sequential id" do
    let(:foreign_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("dni.jpg")),
        filename: "dni.jpg",
        content_type: "image/jpeg"
      )
    end
    let(:image_src) { "/#{foreign_blob.id}" }

    it "does not publish the foreign blob in og:image" do
      expect(response).to have_http_status(:ok)
      expect(og_image).not_to include(foreign_blob.signed_id)
    end
  end

  context "when the body references a foreign blob by an unsigned global id" do
    let(:foreign_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("dni.jpg")),
        filename: "dni.jpg",
        content_type: "image/jpeg"
      )
    end
    let(:image_src) { foreign_blob.to_global_id.to_s }

    it "does not publish the foreign blob in og:image" do
      expect(response).to have_http_status(:ok)
      expect(og_image).not_to include(foreign_blob.signed_id)
    end
  end

  context "when the body references a verification attachment from the same organization" do
    let(:verification_user) { create(:user, :confirmed, organization:) }
    let!(:authorization) do
      create(
        :authorization,
        :pending,
        user: verification_user,
        verification_attachment: Decidim::Dev.test_file("dni.jpg", "image/jpeg")
      )
    end
    let(:image_src) { authorization.verification_attachment.blob.to_global_id.to_s }

    it "does not publish the verification attachment in og:image" do
      expect(response).to have_http_status(:ok)
      expect(og_image).not_to include(authorization.verification_attachment.blob.signed_id)
    end
  end

  context "when the body references a verification attachment from another organization" do
    let(:other_organization) { create(:organization) }
    let(:verification_user) { create(:user, :confirmed, organization: other_organization) }
    let!(:authorization) do
      create(
        :authorization,
        :pending,
        user: verification_user,
        verification_attachment: Decidim::Dev.test_file("dni.jpg", "image/jpeg")
      )
    end
    let(:image_src) { authorization.verification_attachment.blob.to_global_id.to_s }

    it "does not publish the verification attachment in og:image" do
      expect(response).to have_http_status(:ok)
      expect(og_image).not_to include(authorization.verification_attachment.blob.signed_id)
    end
  end
end
