require "spec_helper"

describe Decidim::Admin::CreateParticipatoryProcess do
  let(:organization) { create :organization }
  let(:form) do
    double(
      :invalid? => invalid,
      title: {en: "title"},
      subtitle: {en: "subtitle"},
      slug: "slug",
      hashtag: "hashtag",
      hero_image: nil,
      banner_image: nil,
      promoted: nil,
      description: {en: "description"},
      short_description: {en: "short_description"},
      current_organization: organization
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates a participatory process" do
      expect { subject.call }.to change { Decidim::ParticipatoryProcess.count }.by(1)
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "adds the default step" do
      subject.call do
        on(:ok) do |process|
          expect(process.steps.count).to eq(1)
        end
      end
    end
  end
end
