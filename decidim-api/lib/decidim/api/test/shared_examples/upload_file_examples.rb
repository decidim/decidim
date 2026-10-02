# frozen_string_literal: true

require "tempfile"

shared_examples "API uploadable file" do
  context "when file does not exists" do
    let!(:tempfile) { Tempfile.create(["foo", ".xyz"]) }
    let(:file) { "foobar" }

    it "raises execution error" do
      expect { response }.to raise_error(GraphQL::ExecutionError, /is not a valid upload/)
    end
  end
  context "when file extension is not supported" do
    let!(:tempfile) { Tempfile.create(["foo", ".xyz"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "application/jpeg",
        filename: "foo.xyz"
      )
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File extension is not supported./)
    end
  end

  context "when client-reported content type differs from actual file content" do
    let!(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "application/octet-stream",
        filename: "foo.jpg"
      )
    end

    it "uploads the file using Marcel-detected content type" do
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
