# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::DebateForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_component:,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process) }
  let(:title) do
    Decidim::Faker::Localized.sentence(word_count: 3)
  end
  let(:description) do
    Decidim::Faker::Localized.sentence(word_count: 3)
  end
  let(:instructions) do
    Decidim::Faker::Localized.sentence(word_count: 3)
  end
  let(:start_time) { 2.days.from_now }
  let(:end_time) { 2.days.from_now + 4.hours }
  let(:category) { create(:category, participatory_space: participatory_process) }
  let(:category_id) { category.id }
  let(:parent_scope) { create(:scope, organization:) }
  let(:scope) { create(:subscope, parent: parent_scope) }
  let(:scope_id) { scope.id }
  let(:uploaded_files) { [] }
  let(:current_files) { [] }
  let(:attributes) do
    {
      decidim_category_id: category_id,
      scope_id:,
      title:,
      description:,
      instructions:,
      start_time:,
      end_time:,
      add_documents: uploaded_files,
      documents: current_files
    }
  end

  it_behaves_like "a scopable resource"

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when instructions is missing" do
    let(:instructions) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is missing" do
    let(:start_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when end_time is missing" do
    let(:end_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when both end_time and start_time are missing" do
    let(:end_time) { nil }
    let(:start_time) { nil }

    it { is_expected.to be_valid }
  end

  describe "when start_time is after end_time" do
    let(:start_time) { end_time + 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when end_time is before start_time" do
    let(:end_time) { start_time - 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is equal to start_time" do
    let(:start_time) { end_time }

    it { is_expected.not_to be_valid }
  end

  describe "when the category does not exist" do
    let(:category_id) { category.id + 10 }

    it { is_expected.not_to be_valid }
  end

  describe "when handling attachments" do
    let(:uploaded_files) do
      [
        { file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") },
        { file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
      ]
    end

    it "accepts valid attachments" do
      expect(form).to be_valid
      expect(form.add_documents.count).to eq(2)
    end

    context "when an attachment is invalid" do
      let(:uploaded_files) do
        [
          { file: upload_test_file(Decidim::Dev.asset("invalid_extension.log"), content_type: "text/plain") }
        ]
      end

      it "does not add the invalid file to the form" do
        expect(form.documents).to be_empty
      end
    end
  end

  describe "from model" do
    subject { described_class.from_model(debate).with_context(context) }

    let(:component) { create(:debates_component) }
    let(:category) { create(:category, participatory_space: component.participatory_space) }
    let(:debate) { create(:debate, category:, component:) }
    let!(:attachments) do
      [
        create(:attachment, attached_to: debate, title: { en: "Document 1" }),
        create(:attachment, attached_to: debate, title: { en: "Document 2" })
      ]
    end

    it "sets the form category id correctly" do
      expect(subject.decidim_category_id).to eq category.id
    end

    it "sets the finite value correctly" do
      expect(subject.finite).to be(false)
    end

    it "sets the documents correctly" do
      expect(subject.documents).to match_array(attachments)
      expect(subject.documents.map { |doc| doc.title["en"] }).to eq(["Document 1", "Document 2"])
    end

    context "when the debate has start and end dates" do
      let(:debate) { create(:debate, :open_ama) }

      it "sets the finite value correctly" do
        expect(subject.finite).to be(true)
      end
    end
  end
end
