# frozen_string_literal: true

require "spec_helper"

describe Decidim::UploadModalCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/upload_modal", form, options) }
  let(:form) { Decidim::FormBuilder.new(:object, object, view, {}) }
  let(:view) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:object) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "dummy")
      end

      def model_name
        self.class.model_name
      end
    end.new
  end
  let(:file_field) { double }
  let(:file_validation_humanizer) do
    double(
      uploader: double
    )
  end
  let(:options) do
    {
      attribute:,
      resource_name:,
      attachments:,
      required:,
      titled:
    }
  end
  let(:attribute) { "dummy_attribute" }
  let(:resource_name) { "dummy" }
  let(:attachments) { [] }
  let(:required) { false }
  let(:titled) { false }

  before do
    allow(Decidim::FileValidatorHumanizer).to receive(:new).and_return(file_validation_humanizer)
  end

  it "renders the open button" do
    expect(subject).to have_css("[data-upload][type='button']")
  end

  it "renders modal" do
    expect(subject).to have_css(".upload-modal")
  end

  it "renders dropzone" do
    expect(subject).to have_css("[data-dropzone]")
  end

  context "when file is required" do
    let(:required) { true }

    it "renders hidden checkbox" do
      expect(subject).to have_css("input[name='dummy[#{attribute}_validation]']", visible: :hidden)
    end

    it "renders the required field indicator" do
      expect(subject).to have_css("label .label-required", text: "Required field")
    end
  end

  context "when attachment is present" do
    let(:filename) { "Exampledocument.pdf" }
    let(:file) { Decidim::Dev.test_file(filename, "application/pdf") }
    let(:attachments) { [upload_test_file(file)] }

    it "renders the attachments" do
      expect(subject).to have_css(".attachment-details")
      expect(subject).to have_css("[data-filename='#{filename}']")
    end

    context "when attachment is image" do
      let(:filename) { "city.jpeg" }
      let(:file) { Decidim::Dev.test_file(filename, "image/jpeg") }

      it "renders preview" do
        expect(subject.find("img")["src"]).to match(%r{/city.jpeg$})
      end
    end

    context "when attachment is titled" do
      let(:attachments) { [create(:attachment, file:)] }
      let(:titled) { true }

      before do
        allow(form).to receive(:hidden_field).and_return(
          %(<input type="hidden" name="#{attribute}[]" value="#{attachments[0].id}">)
        )
      end

      it "renders the attachments" do
        expect(subject).to have_css(".attachment-details")
        expect(subject).to have_css("[data-filename='#{filename}']")

        details = subject.find(".attachment-details")
        expect(details).to have_content("#{decidim_sanitize_translated(attachments[0].title)}")
      end
    end

    context "when there is rich content in the filename" do
      let(:blob) { ActiveStorage::Blob.find_signed(attachments.first) }

      before do
        blob.update!(filename: "<svg onload=alert('ALERT')>.pdf")
      end

      it "escapes the truncated filename" do
        expect(my_cell.send(:truncated_file_name_for, attachments.first)).to eq("&lt;svg onload=alert(&#39;ALERT&#39;)&gt;.pdf")
      end

      it "escapes the filename" do
        expect(my_cell.send(:file_name_for, attachments.first)).to eq("&lt;svg onload=alert(&#39;ALERT&#39;)&gt;.pdf")
      end
    end
  end

  context "when multiple attachments are present" do
    let(:filename1) { "Exampledocument.pdf" }
    let(:filename2) { "city.jpeg" }
    let(:file1) { Decidim::Dev.test_file(filename1, "application/pdf") }
    let(:file2) { Decidim::Dev.test_file(filename2, "image/jpeg") }
    let(:attachments) { [upload_test_file(file1), upload_test_file(file2)] }

    it "renders the attachments" do
      expect(subject).to have_css(".attachment-details", count: 2)
      expect(subject).to have_css("[data-filename='Exampledocument.pdf']")
      expect(subject).to have_css("[data-filename='city.jpeg']")
      expect(subject).to have_css("img")
      expect(subject.find("img")["src"]).to match(%r{/city.jpeg$})
    end

    context "when all attachments are images" do
      let(:file1) { Decidim::Dev.test_file("city.jpeg", "application/pdf") }
      let(:file2) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }

      it "renders preview" do
        images = subject.all("img")
        expect(images.count).to be(2)
        expect(images[0]["src"]).to match(%r{/city.jpeg$})
        expect(images[1]["src"]).to match(%r{/city2.jpeg$})
      end
    end

    context "when attachment is titled" do
      let(:attachments) { [create(:attachment, file: file1), create(:attachment, file: file2)] }
      let(:titled) { true }

      before do
        allow(form).to receive(:hidden_field).and_return(
          %(<input type="hidden" name="#{attribute}[]" value="#{attachments[0].id}">)
        )
      end

      it "renders the attachments" do
        expect(subject).to have_css(".attachment-details", count: 2)
        expect(subject).to have_css("[data-filename='#{filename1}']")

        details = subject.find(".attachment-details", match: :first)
        expect(details).to have_content("#{decidim_sanitize_translated(attachments[0].title)}")
      end
    end

    context "when there is a title" do
      let(:titled) { true }
      let(:attachment) do
        instance_double(
          Decidim::Attachment,
          title: { en: title },
          id: 123,
          url: "https://example.org/file.png"
        )
      end
      let(:attachments) { [attachment] }
      let(:title) { "An image title" }

      it "renders the title" do
        expect(subject).to have_css(".attachment-details")
        expect(subject).to have_content("An image title")
      end

      context "when there is rich content in the title" do
        let(:title) { "An image <script>alert(\"ALERT\")</script>" }

        it "renders the title" do
          expect(subject).to have_content("An image alert(\"ALERT\")")
        end

        it "escapes the title" do
          expect(my_cell.send(:title_for, attachment)).to eq("An image alert(&quot;ALERT&quot;)")
        end
      end
    end
  end

  context "when the engine is mounted on a different route" do
    let(:path) { "/app/upload_validations" }

    before do
      allow(Decidim::Core::Engine.routes.url_helpers).to receive(:upload_validations_path).and_return(path)
    end

    it "generates a path relative to the mount location" do
      expect(my_cell.send(:upload_validations_url)).to eq(path)
    end
  end
end
