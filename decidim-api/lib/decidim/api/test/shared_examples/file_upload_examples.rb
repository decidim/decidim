# frozen_string_literal: true

require "tempfile"

# The checks applied to a file before it is stored as a blob. They are shared by
# the GraphQL entry points which receive an upload from the client, so that the
# same rules are verified through each of them.
#
# The scenarios which reject the file check the error and that nothing is stored.
# The ones which accept it only check the blob, as what happens with it afterwards
# differs between entry points: the upload mutation returns it, the attachment
# mutations attach it to a record which runs the model upload validations. The
# files which are accepted here are therefore valid documents, so that the model
# validations do not interfere, and each entry point checks its own result in its
# own spec.
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

  def maximum_file_size
    10.kilobytes.to_f / 1.megabyte
  end

  def expect_file_is_not_stored(message)
    count = ActiveStorage::Blob.count

    expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, message)

    expect(ActiveStorage::Blob.count).to eq(count)
  end

  def expect_file_is_stored
    expect { response }.to change(ActiveStorage::Blob, :count).by(1)
  end

  context "when the file does not exist" do
    let(:file) { "foobar" }

    it "raises an execution error" do
      expect { response }.to raise_error(GraphQL::ExecutionError, /is not a valid upload/)
    end
  end

  context "when the file extension is not supported" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Tempfile.create(["foo", ".xyz"]).path,
        "application/jpeg",
        filename: "foo.xyz"
      )
    end

    it "does not store the file" do
      expect_file_is_not_stored(/File extension is not supported./)
    end
  end

  context "when the file name has no extension" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "image/jpeg",
        filename: "city"
      )
    end

    it "does not store the file" do
      expect_file_is_not_stored(/File extension is not supported./)
    end
  end

  context "when the content type declared by the client is not allowed" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "application/zip",
        filename: "city.jpeg"
      )
    end

    it "does not store the file" do
      expect_file_is_not_stored(/File type is not supported./)
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

    it "does not store the file" do
      expect_file_is_not_stored(/File type is not supported./)
    end
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

    it "does not store the file" do
      expect_file_is_not_stored(/File contains unsafe content./)
    end
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

    it "does not store the file" do
      expect_file_is_not_stored(/File contains unsafe content./)
    end
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

    it "does not store the file" do
      expect_file_is_not_stored(/File contains unsafe content./)
    end
  end

  context "when the file size is larger than the configured maximum" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("city.jpeg"),
        "image/jpeg",
        filename: "city.jpeg"
      )
    end

    before do
      current_organization.settings.upload.maximum_file_size.default = maximum_file_size
    end

    it "does not store the file" do
      expect_file_is_not_stored(/File is too large./)
    end
  end

  context "when the declared content type is allowed but differs from the file contents" do
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        Decidim::Dev.asset("icon.png"),
        "image/jpeg;charset=binary",
        filename: "icon.png"
      )
    end

    it "stores the content type detected from the contents, without the parameters" do
      expect_file_is_stored

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

    it "stores the file" do
      expect_file_is_stored
    end
  end

  context "when the file size equals the configured maximum" do
    # A text file is used so that the model upload validations, which run after the
    # blob is stored in the entry points which create a record, also accept it.
    let!(:tempfile) { Tempfile.create(["report", ".txt"]) }
    let(:file) do
      Rack::Multipart::UploadedFile.new(
        tempfile.path,
        "text/plain",
        filename: "report.txt"
      )
    end

    before do
      tempfile.write("a" * 10_240)
      tempfile.rewind

      current_organization.settings.upload.maximum_file_size.default = maximum_file_size
    end

    it "stores the file" do
      expect_file_is_stored
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
      expect_file_is_stored

      expect(ActiveStorage::Blob.last.filename.to_s).to eq(filename.scrub)
    end
  end

  context "when everything is ok" do
    it "stores the file" do
      expect_file_is_stored
    end
  end
end
