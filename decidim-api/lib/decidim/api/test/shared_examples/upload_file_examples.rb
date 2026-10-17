# frozen_string_literal: true

require "tempfile"

shared_examples "API uploadable file" do
  shared_examples "does not store the file" do
    it "does not create the blob" do
      count = ActiveStorage::Blob.count

      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError)

      expect(ActiveStorage::Blob.count).to eq(count)
    end
  end

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

    include_examples "does not store the file"
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

    it "stores the content type detected from the file contents" do
      response

      expect(ActiveStorage::Blob.last.content_type).to eq("image/jpeg")
    end
  end

  context "when the content type detected from the file contents is not allowed" do
    let!(:tempfile) { Tempfile.create(["spoofed", ".png"]) }
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        filename: "spoofed.png",
        type: "image/png",
        tempfile:
      )
    end

    before do
      # An HTML document with an image extension: the extension is allowed, the
      # content type detected from the contents is not.
      tempfile.write("<html><body>Not an image</body></html>")
      tempfile.rewind
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File type is not supported./)
    end

    include_examples "does not store the file"
  end

  context "when the SVG document contains active content" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("malicious_svg_script.svg"),
        "image/svg+xml",
        filename: "malicious_svg_script.svg"
      )
    end

    before do
      # SVG is not in the default allowlists, so it has to be allowed for the
      # contents to be checked against the document itself.
      current_organization.settings.tap do |settings|
        settings.upload.allowed_file_extensions.admin = %w(svg)
      end
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File contains unsafe content./)
    end

    include_examples "does not store the file"
  end

  context "when the SVG document is not a well formed SVG document" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("malformed_svg_unclosed_element.svg"),
        "image/svg+xml",
        filename: "malformed_svg_unclosed_element.svg"
      )
    end

    before do
      current_organization.settings.tap do |settings|
        settings.upload.allowed_file_extensions.admin = %w(svg)
      end
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File contains unsafe content./)
    end

    include_examples "does not store the file"
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
      current_organization.settings.tap do |settings|
        settings.upload.allowed_file_extensions.admin = %w(svg)
      end
    end

    it "uploads the file and returns the blob" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)
    end
  end

  context "when file size is larger than the configured maximum" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "image/jpeg",
        filename: "city.jpeg"
      )
    end

    before do
      current_organization.settings.tap do |settings|
        settings.upload.maximum_file_size.default = 10.kilobytes.to_f / 1.megabyte
      end
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File is too large./)
    end

    include_examples "does not store the file"
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
