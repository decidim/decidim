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

  context "when content type is not supported" do
    let!(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "application/octet-stream",
        filename: "foo.jpg"
      )
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File type is not supported./)
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
