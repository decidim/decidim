# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess do
  subject { described_class.new(form) }

  let(:organization) { create :organization }
  let(:participatory_process_group) { create :participatory_process_group, organization: organization }
  let(:scope) { create :scope, organization: organization }
  let(:errors) { double.as_null_object }
  let(:form) do
    instance_double(
      Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm,
      invalid?: invalid,
      title: { en: "title" },
      subtitle: { en: "subtitle" },
      slug: "slug",
      hashtag: "hashtag",
      meta_scope: "meta scope",
      hero_image: nil,
      banner_image: nil,
      promoted: nil,
      developer_group: "developer group",
      local_area: "local",
      target: "target",
      participatory_scope: "participatory scope",
      participatory_structure: "participatory structure",
      start_date: nil,
      end_date: nil,
      description: { en: "description" },
      short_description: { en: "short_description" },
      current_organization: organization,
      scopes_enabled: true,
      scope: scope,
      errors: errors,
      participatory_process_group: participatory_process_group
    )
  end
  let(:invalid) { false }

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

    it "adds the default active step" do
      subject.call do
        on(:ok) do |process|
          expect(process.steps.count).to eq(1)
          expect(process.steps.first).to be_active
        end
      end
    end
  end
end
