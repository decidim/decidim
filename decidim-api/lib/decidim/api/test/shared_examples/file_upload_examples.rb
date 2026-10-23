# frozen_string_literal: true

require "tempfile"

# The checks applied to a file before it is stored as a blob. They are shared by
# the GraphQL entry points which receive an upload from the client, so that the
# same rules are verified through each of them.
#
# Only the rejections are shared for every entry point: once the blob is stored,
# what happens next differs (the upload mutation returns the blob, the attachment
# mutations save a record which runs the model upload validations), so the
# scenarios which accept the file only check the result which is common to both.
shared_examples "file upload validation rules" do
  # The allowlists depend on the role which performs the upload, so both of them
  # are set here: these examples are exercised through the entry points used by
  # administrators and by participants.
  def allow_svg_uploads
    current_organization.settings.tap do |settings|
      settings.upload.allowed_file_extensions.default = %w(svg)
      settings.upload.allowed_file_extensions.admin = %w(svg)
    end
  end

  shared_examples "does not store the file" do
    it "does not create the blob" do
      count = ActiveStorage::Blob.count

      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError)

      expect(ActiveStorage::Blob.count).to eq(count)
    end
  end

  context "when file does not exists" do
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

  context "when the file name has no extension" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "image/jpeg",
        filename: "city"
      )
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File extension is not supported./)
    end

    include_examples "does not store the file"
  end

  context "when the content type declared by the client is not allowed" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "application/zip",
        filename: "city.jpeg"
      )
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File type is not supported./)
    end

    include_examples "does not store the file"
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
      allow_svg_uploads
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
      allow_svg_uploads
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File contains unsafe content./)
    end

    include_examples "does not store the file"
  end

  context "when an XML document is declared as SVG" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("spoofed_svg_xml.svg"),
        "image/svg+xml",
        filename: "spoofed_svg_xml.svg"
      )
    end

    before do
      allow_svg_uploads
    end

    it "raises execution error" do
      expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File contains unsafe content./)
    end

    include_examples "does not store the file"
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

  context "when the declared content type includes parameters" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("icon.png"),
        "image/png;charset=binary",
        filename: "icon.png"
      )
    end

    it "stores the content type detected from the contents, without the parameters" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)

      expect(ActiveStorage::Blob.last.content_type).to eq("image/png")
    end
  end

  context "when the file name has byte sequences which are not valid in UTF-8" do
    # A name in another encoding read as UTF-8: the byte sequences cannot be stored
    # in the database, so they are replaced before the blob is created. Rack cannot
    # build the uploaded file with such a name, so it is forced on the instance, as
    # a multipart request would deliver it.
    let(:filename) { "êxämplö®'.pdf".encode("WINDOWS-1252").force_encoding("UTF-8") }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("Exampledocument.pdf"),
        "application/pdf"
      ).tap do |uploaded_file|
        uploaded_file.instance_variable_set(:@original_filename, filename)
      end
    end

    it "stores the file with the invalid sequences replaced" do
      expect { response }.to change(ActiveStorage::Blob, :count).by(1)

      expect(ActiveStorage::Blob.last.filename.to_s).to eq(filename.scrub)
    end
  end
end
