require "spec_helper"

describe Decidim::Admin::CreateParticipatoryProcess do
  let(:organization) { create :organization }
  let(:scope) { create :scope, organization: organization }
  let(:errors) { double.as_null_object }
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
      current_organization: organization,
      scopes: [scope],
      errors: errors
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is not persisted" do
    let(:invalid_process) do
      instance_double(
        Decidim::ParticipatoryProcess,
        persisted?: false,
        valid?: false,
        errors: {
          hero_image: "Image too big",
          banner_image: "Image too big"
        }
      ).as_null_object
    end

    before do
      expect(Decidim::ParticipatoryProcess).to receive(:new).and_return(invalid_process)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "adds errors to the form" do
      expect(errors).to receive(:add).with(:hero_image, "Image too big")
      expect(errors).to receive(:add).with(:banner_image, "Image too big")
      subject.call
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
