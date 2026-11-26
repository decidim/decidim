# frozen_string_literal: true

require "spec_helper"

describe "Comment body blob references" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :published, organization:) }
  let(:component) { create(:component, :published, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, :published, component:) }
  let(:participant) { create(:user, :confirmed, locale: "en", organization:) }
  let(:headers) { { "HOST" => organization.host } }

  let(:other_organization) { create(:organization) }
  let(:victim) { create(:user, :confirmed, organization: other_organization) }
  let!(:id_document_authorization) do
    create(
      :authorization,
      :pending,
      name: "id_documents",
      user: victim,
      verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpeg")
    )
  end
  let!(:private_export) { create(:private_export, organization: other_organization, attached_to: victim) }

  let(:public_blob) { create(:editor_image, organization:).file.blob }

  before { login_as participant, scope: :user }

  def post_comment(body)
    post(
      "/comments",
      params: { comment: { commentable_gid: commentable.to_signed_global_id.to_s, body:, alignment: 0 } },
      headers:,
      xhr: true
    )
    expect(response).to have_http_status(:ok)
    response.body
  end

  # ActiveStorage URLs inside the rendered comment text (not the avatar etc.)
  def blob_urls_in(body)
    content = body[%r{class=\\"editor-content\\">(.*?)<\\/div>}m, 1].to_s
    content.scan(%r{/rails/active_storage/[^\s"'<>\\]+})
  end

  def private_download_urls_in(body)
    content = body[%r{class=\\"editor-content\\">(.*?)<\\/div>}m, 1].to_s
    content.scan(%r{/private_downloads/[^\s"'<>\\]+})
  end

  def blob_for(url)
    if (key = url[%r{/rails/active_storage/disk/([^/]+)/}, 1])
      decoded = ActiveStorage.verifier.verified(key, purpose: :blob_key)&.with_indifferent_access
      ActiveStorage::Blob.find_by(key: decoded[:key]) if decoded
    elsif (signed_id = url[%r{/rails/active_storage/(?:blobs|representations)/(?:redirect/|proxy/)?([^/]+)/}, 1])
      ActiveStorage::Blob.find_signed(signed_id)
    end
  end

  def blobs_in(body)
    blob_urls_in(body).filter_map { |url| blob_for(url) }
  end

  def download(url)
    get(url, headers:)
    follow_redirect! while response.redirect?
    response.body.b
  end

  describe "control" do
    it "renders a working URL for a blob that belongs to a public record in the current organization" do
      body = post_comment("My picture #{public_blob.to_global_id}")

      expect(Decidim::Comments::Comment.last.body["en"]).to eq("My picture #{public_blob.to_global_id}")
      expect(blobs_in(body)).to eq([public_blob])
      expect(download(blob_urls_in(body).first)).to eq(File.binread(Decidim::Dev.asset("city.jpeg")))
    end
  end

  describe "security" do
    let(:id_scan_blob) { id_document_authorization.verification_attachment.blob }
    let(:export_blob) { private_export.file.blob }

    it "does not render an Active Storage URL for the pending verification document of another organization" do
      expect(id_scan_blob).to be_persisted
      body = post_comment("Look #{id_scan_blob.to_global_id}")

      expect(blobs_in(body).map(&:id)).not_to include(id_scan_blob.id)
      expect(blob_urls_in(body)).to be_empty
      expect(private_download_urls_in(body)).not_to be_empty
    end

    it "does not let the participant download the verification document through a private download URL" do
      body = post_comment("Look #{id_scan_blob.to_global_id}")
      private_url = private_download_urls_in(body).first

      expect(private_url).to be_present
      get(private_url, headers:)
      expect(response).to have_http_status(:not_found)
    end

    it "does not render an Active Storage URL for the private export of another organization" do
      expect(export_blob).to be_persisted
      body = post_comment("Look #{export_blob.to_global_id}")

      expect(blobs_in(body).map(&:id)).not_to include(export_blob.id)
      expect(blob_urls_in(body)).to be_empty
      expect(private_download_urls_in(body)).not_to be_empty
    end

    it "does not render an Active Storage URL for a public blob from another organization" do
      other_blob = create(:editor_image, organization: other_organization).file.blob
      body = post_comment("Look #{other_blob.to_global_id}")

      expect(blobs_in(body).map(&:id)).not_to include(other_blob.id)
      expect(blob_urls_in(body)).to be_empty
      expect(private_download_urls_in(body)).to be_empty
    end

    it "does not render an Active Storage URL for an unattached blob" do
      unattached_blob = create(:blob, :image)
      body = post_comment("Look #{unattached_blob.to_global_id}")

      expect(blobs_in(body).map(&:id)).not_to include(unattached_blob.id)
      expect(blob_urls_in(body)).to be_empty
      expect(private_download_urls_in(body)).to be_empty
    end

    it "lets the owner download the verification document through the private download URL" do
      body = post_comment("Look #{id_scan_blob.to_global_id}")
      private_url = private_download_urls_in(body).first

      logout(:user)
      login_as victim, scope: :user
      get(private_url, headers: { "HOST" => other_organization.host })

      expect(response).to have_http_status(:ok)
      expect(Digest::SHA256.hexdigest(response.body.b)).to eq(Digest::SHA256.file(Decidim::Dev.asset("id.jpg")).hexdigest)
    end
  end
end
