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
      titled:,
      redesigned:
    }
  end
  let(:attribute) { "dummy_attribute" }
  let(:resource_name) { "dummy" }
  let(:attachments) { [] }
  let(:required) { false }
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
        required:,
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
    let(:required) { true }

    it "renders hidden checkbox" do
      expect(subject).to have_css("input[name='dummy[#{attribute}_validation]']")
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
      expect(subject).to have_selector("[data-filename='#{filename}']")
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
        expect(subject).to have_selector("[data-filename='#{filename}']")

        details = subject.find(".attachment-details")
        expect(details).to have_content("#{attachments[0].title["en"]} (#{filename})")
      end
    end
  end

  context "when multiple attachments are present" do
    let(:file1) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
    let(:file2) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    let(:attachments) { [upload_test_file(file1), upload_test_file(file2)] }

    it "renders the attachments" do
      expect(subject).to have_css(".attachment-details", count: 2)
      expect(subject).to have_selector("[data-filename='Exampledocument.pdf']")
      expect(subject).to have_selector("[data-filename='city.jpeg']")
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
      let(:attachments) { [create(:attachment, file:)] }
      let(:titled) { true }

      before do
        allow(form).to receive(:hidden_field).and_return(
          %(<input type="hidden" name="#{attribute}[]" value="#{attachments[0].id}">)
        )
      end

      it "renders the attachments" do
        expect(subject).to have_css(".attachment-details")
        expect(subject).to have_selector("[data-filename='#{filename}']")

        details = subject.find(".attachment-details")
        expect(details).to have_content("#{attachments[0].title["en"]} (#{filename})")
      end
    end
  end
end
