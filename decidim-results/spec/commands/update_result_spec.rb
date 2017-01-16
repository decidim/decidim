require "spec_helper"

describe Decidim::Results::Admin::UpdateResult do
  let(:result) { create :result}
  let(:organization) { result.feature.organization }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: result.feature.participatory_process }
  let(:form) do
    double(
      :invalid? => invalid,
      title: {en: "title"},
      description: {en: "description"},
      short_description: {en: "short_description"},
      scope: scope,
      category: category
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, result) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the result" do
      subject.call
      expect(translated(result.title)).to eq "title"
    end

    it "sets the scope" do
      subject.call
      expect(result.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(result.category).to eq category
    end
  end
end
