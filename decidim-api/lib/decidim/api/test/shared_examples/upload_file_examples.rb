# frozen_string_literal: true

require "tempfile"

shared_examples "API uploadable file" do
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
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError, match(/File extension is not supported./))
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
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError, match(/File type is not supported./))
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
      result = nil

      expect do
        result = execute_query(query, variables)
      end.to change(ActiveStorage::Blob, :count).by(1)

      blob = ActiveStorage::Blob.last
      expect(result["uploadFile"]["blob"]).to include(
        "id" => blob.id.to_s,
        "filename" => blob.filename,
        "checksum" => blob.checksum,
        "signedId" => blob.signed_id,
        "byteSize" => blob.byte_size,

      )
    end
  end
end
