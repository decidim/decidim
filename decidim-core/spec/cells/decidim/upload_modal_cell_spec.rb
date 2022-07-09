# frozen_string_literal: true

require "spec_helper"

describe Decidim::UploadModalCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/upload_modal", form, options) }
  let(:form) do
    double(
      object: object,
      object_name: "object",
      file_field: file_field,
      abide_error_element: "",
      error_and_help_text: ""
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
      attribute: attribute,
      resource_name: resource_name,
      attachments: attachments,
      optional: optional,
      titled: titled
    }
  end
  let(:attribute) { "dummy_attribute" }
  let(:resource_name) { "dummy" }
  let(:attachments) { [] }
  let(:optional) { true }
  let(:titled) { false }

  before do
    allow(Decidim::FileValidatorHumanizer).to receive(:new).and_return(file_validation_humanizer)
  end

  it "renders the open button" do
    expect(subject).to have_css(".add-file[type='button']")
  end

  it "renders modal" do
    expect(subject).to have_css(".upload-modal")
  end

  it "renders dropzone" do
    expect(subject).to have_css(".dropzone")
  end

  context "when file is required" do
    let(:optional) { false }
    let(:object) do
      double(
        model_name: double(
          param_key: param_key
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
  end
end
