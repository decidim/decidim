# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssembly do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:scope) { create :scope, organization: organization }
    let(:area) { create :area, organization: organization }
    let(:errors) { double.as_null_object }
    let(:form) do
      instance_double(
        Admin::AssemblyForm,
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
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_organization: organization,
        scopes_enabled: true,
        scope: scope,
        area: area,
        errors: errors
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the assembly is not persisted" do
      let(:invalid_assembly) do
        instance_double(
          Decidim::Assembly,
          persisted?: false,
          valid?: false,
          errors: {
            hero_image: "Image too big",
            banner_image: "Image too big"
          }
        ).as_null_object
      end

      before do
        expect(Decidim::Assembly).to receive(:new).and_return(invalid_assembly)
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
      it "creates an assembly" do
        expect { subject.call }.to change { Decidim::Assembly.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
