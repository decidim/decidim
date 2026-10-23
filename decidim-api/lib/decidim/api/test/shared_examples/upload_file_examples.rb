# frozen_string_literal: true

require "tempfile"

shared_examples "API uploadable file" do
  include_examples "file upload validation rules"

  context "when the declared content type is allowed but differs from the file contents" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("icon.png"),
        "image/jpeg",
        filename: "icon.png"
      )
    end

    it "stores the content type detected from the file contents" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)

      expect(ActiveStorage::Blob.last.content_type).to eq("image/png")
    end
  end

  context "when the SVG document does not contain active content" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("test.svg"),
        "image/svg+xml",
        filename: "test.svg"
      )
    end

    before do
      allow_svg_uploads
    end

    it "uploads the file and returns the blob" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)
    end
  end

  context "when file size equals the configured maximum" do
    let!(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "image/jpg",
        filename: "foo.jpg"
      )
    end

    before do
      tempfile.write("a" * 10_240)
      tempfile.rewind

      current_organization.settings.tap do |settings|
        settings.upload.maximum_file_size.default = 10.kilobytes.to_f / 1.megabyte
      end
    end

    it "uploads the file and returns the blob" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)
    end
  end

  context "when everything is ok" do
    let!(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "image/jpg",
        filename: "foo.jpg"
      )
    end

    it "uploads the file and returns the blob" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)

      blob = ActiveStorage::Blob.last
      expect(response["uploadFile"]["blob"]).to include(
        "id" => blob.id.to_s,
        "filename" => blob.filename,
        "checksum" => blob.checksum,
        "signedId" => blob.signed_id,
        "byteSize" => blob.byte_size
      )
    end
  end
end
