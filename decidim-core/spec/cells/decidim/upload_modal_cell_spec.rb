# frozen_string_literal: true

require "spec_helper"

describe Decidim::UploadModalCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/upload_modal", form, options) }
  let(:form) do
    double(
      object:,
      object_name: "object",
      file_field:,
      abide_error_element: "",
      error_and_help_text: "",
      hidden_field: ""
    )
  end
  let(:object) do
    double
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
      optional:,
      titled:,
      redesigned:
    }
  end
  let(:attribute) { "dummy_attribute" }
  let(:resource_name) { "dummy" }
  let(:attachments) { [] }
  let(:optional) { true }
  let(:titled) { false }
  let(:redesigned) { false }

  shared_examples "a not redesigned cell" do
    it "renders the open button" do
      expect(subject).to have_css(".add-file[type='button']")
    end

    it "renders modal" do
      expect(subject).to have_css(".upload-modal")
    end

    it "renders dropzone" do
      expect(subject).to have_css(".dropzone")
    end
  end

  shared_examples "a redesigned cell" do
    it "renders the open button" do
      expect(subject).to have_css("[data-upload][type='button']")
    end

    it "renders modal" do
      expect(subject).to have_css(".upload-modal")
    end

    it "renders dropzone" do
      expect(subject).to have_css("[data-dropzone]")
    end
  end

  before do
    allow(Decidim::FileValidatorHumanizer).to receive(:new).and_return(file_validation_humanizer)
  end

  context "without redesigned option" do
    let(:options) do
      {
        attribute:,
        resource_name:,
        attachments:,
        optional:,
        titled:
      }
    end

    it_behaves_like "a not redesigned cell"
  end

  context "with redesigned option disabled" do
    it_behaves_like "a not redesigned cell"
  end

  context "with redesigned option enabled" do
    let(:redesigned) { true }

    it_behaves_like "a redesigned cell"
  end

  context "when file is required" do
    let(:optional) { false }
    let(:object) do
      double(
        model_name: double(
          param_key:
        )
      )
    end
    let(:param_key) { "dummy_param_key" }

    it "renders hidden checkbox" do
      expect(subject).to have_css("input[name='#{param_key}[#{attribute}_validation]']")
    end
  end

  context "when attachment is present" do
    let(:filename) { "Exampledocument.pdf" }
    let(:attachments) { [upload_test_file(Decidim::Dev.test_file(filename, "application/pdf"))] }

    it "renders the attachments" do
      expect(subject).to have_css(".attachment-details")
      expect(subject).to have_selector("[data-filename='#{filename}']")
    end

    context "when attachment is image" do
      let(:filename) { "city.jpeg" }

      it "renders preview" do
        expect(subject).to have_selector("img[alt='#{attribute}']")
      end
    end

    context "when there's a title" do
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

      context "when there's rich content in the title" do
        let(:title) { "An image <script>alert(\"ALERT\")</script>" }

        it "renders the title" do
          expect(subject).to have_content("An image alert(\"ALERT\")")
        end
      end
    end
  end
end
