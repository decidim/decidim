# frozen_string_literal: true

require "tempfile"

shared_examples "API uploadable file" do
  it_behaves_like "handle form error"
end

shared_examples "handle form error" do
  context "when file not found" do
    let!(:file_path) { "/path/to/nonexistent/file.jpg" }

    it "raises execution error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end

  context "when file extension is not supported" do
    let!(:file) { Tempfile.create(["foo", ".xyz"]) }

    let!(:file_path) { file.path }

    it "raises execution error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError, match(/File extension is not supported./))
    end
  end

  context "when content type is not supported" do
    let!(:file) { Tempfile.create("fake_file") }
    let!(:file_path) { file.path }

    before do
      allow(Marcel::MimeType).to receive(:for).and_return("unsupported/type")
    end

    it "raises execution error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError, match(/File type is not supported./))
    end
  end

  context "when everything is ok" do
    let!(:file) { Tempfile.create(["valid_file", ".jpeg"]) }
    before do
      allow(Marcel::MimeType).to receive(:for).and_return("image/jpeg")
    end

    it "uploads the file and returns the blob" do
      result = nil

      expect {
        result = execute_query(query, variables)
      }.to change(ActiveStorage::Blob, :count).by(1)

      blob = ActiveStorage::Blob.last

      expect(result["uploadFile"]["blob"]).to include(
        "id" => blob.id.to_s,
        "signedId" => blob.signed_id,
        "filename" => blob.filename,
        "contentType" => "image/jpeg"
      )
    end
  end
end