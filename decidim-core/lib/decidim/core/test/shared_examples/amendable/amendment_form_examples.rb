# frozen_string_literal: true

shared_examples "an amendment form" do
  let(:title) { "More sidewalks and less roads!" }
  let(:body) { "Everything would be better" }
  let(:emendation_params) do
    {
      title:,
      body:
    }
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when there's no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }

    it "only adds errors to this field" do
      subject.valid?
      expect(subject.errors.attribute_names).to eq [:title]
    end
  end

  context "when the title is too long" do
    let(:body) { "A" * 200 }

    it { is_expected.to be_invalid }
  end

  context "when the body is not etiquette-compliant" do
    let(:body) { "A" }

    it { is_expected.to be_invalid }
  end

  context "when there's no body" do
    let(:body) { nil }

    it { is_expected.to be_invalid }
  end
end
