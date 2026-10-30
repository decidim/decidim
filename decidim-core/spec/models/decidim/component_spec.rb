# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let!(:organization) { create(:organization) }
    let(:component) { build(:component, manifest_name: "dummy", organization:) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"
    include_examples "taxonomy settings"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::ComponentPresenter
    end

    describe "#settings" do
      before { component }

      it "builds the settings only once for repeated reads" do
        expect(described_class).to receive(:build_settings).with(component.manifest, :global, anything, organization).once.and_call_original

        3.times { expect(component.settings.comments_enabled).to be true }
      end

      it "keeps assignments to returned settings separate" do
        settings = component.settings
        settings.comments_enabled = false
        settings.taxonomy_filters << 123
        settings.dummy_global_translatable_text["en"] = "Changed"
        settings.errors.add(:base, "Invalid")

        expect(component.settings).not_to equal(settings)
        expect(component.settings.comments_enabled).to be true
        expect(component.settings.taxonomy_filters).to be_empty
        expect(component.settings.dummy_global_translatable_text["en"]).not_to eq("Changed")
        expect(component.settings.errors).to be_empty
      end

      it "updates the cache when settings are assigned" do
        component.settings
        component.settings = { comments_enabled: false }

        expect(component.settings.comments_enabled).to be false
      end

      it "keeps localized rich text strings separate" do
        component.settings = { dummy_global_translatable_text_en: "Original" }
        component.settings.dummy_global_translatable_text["en"].replace("Changed")

        expect(component.settings.dummy_global_translatable_text["en"]).to eq("Original")
      end

      it "updates the cache when the raw settings change" do
        component.settings
        component[:settings]["global"][:comments_enabled] = false

        expect(component.settings.comments_enabled).to be false
      end

      it "updates the cache when nested raw settings change" do
        component.settings
        component[:settings]["global"][:dummy_global_translatable_text]["en"] = "Changed"

        expect(component.settings.dummy_global_translatable_text["en"]).to eq("Changed")
      end

      it "updates the cache when the organization's default locale changes" do
        component.settings
        organization.default_locale = "ca"

        expect(component.settings.default_locale).to eq("ca")

        organization.default_locale.replace("es")

        expect(component.settings.default_locale).to eq("es")
      end

      it "updates the cache when the manifest changes" do
        component.settings
        component.manifest_name = "proposals"

        expect(component.settings).to be_a(component.manifest.settings(:global).schema)
      end

      it "does not share cached settings between components" do
        other_component = build(:component, organization:, settings: { comments_enabled: false })
        component.settings

        expect(other_component.settings.comments_enabled).to be false
        expect(component.settings.comments_enabled).to be true
      end

      it "does not share the settings cache with a duplicate" do
        component.settings
        duplicate = component.dup
        expect(described_class).to receive(:build_settings).with(duplicate.manifest, :global, anything, organization).once.and_call_original

        expect(duplicate.settings.comments_enabled).to be true
      end

      context "when persisted" do
        before { component.save! }

        it "keeps localized rich text strings separate after reload" do
          component.update!(settings: { dummy_global_translatable_text_en: "Original" })
          component.reload.settings.dummy_global_translatable_text["en"].replace("Changed")

          expect(component.settings.dummy_global_translatable_text["en"]).to eq("Original")
        end

        it "does not mark stored settings as changed when read" do
          component.reload
          3.times { component.settings.to_h }

          expect(component).not_to be_changed
        end

        it "updates the cache after reloading changed settings" do
          component.settings
          described_class.find(component.id).update!(settings: { comments_enabled: false })

          expect(component.reload.settings.comments_enabled).to be false
        end

        it "rebuilds settings after reloading unchanged data" do
          component.settings
          component.reload
          expect(described_class).to receive(:build_settings).with(component.manifest, :global, anything, organization).once.and_call_original

          component.settings
        end
      end

      it "returns empty settings without a manifest" do
        component.manifest_name = "missing"

        expect(component.settings).to eq({})
      end

      it "returns empty settings without a participatory space" do
        component.participatory_space = nil

        expect(component.settings).to eq({})
      end
    end

    describe "default scope" do
      subject { described_class.all }

      it "orders the components by weight and by manifest name" do
        described_class.destroy_all

        component_b = create(:component, manifest_name: "proposals", weight: 0)
        component_c = create(:component, manifest_name: :dummy, weight: 2)
        component_a = create(:component, manifest_name: :dummy, weight: 0)

        expect(subject).to eq [component_a, component_b, component_c]
      end
    end

    describe ".for_organization" do
      subject { described_class.for_organization(organization:) }

      let!(:component) { create(:component, manifest_name: "dummy", organization:) }
      let!(:assembly_component) do
        create(:component, manifest_name: "dummy", organization:, participatory_space: create(:assembly, organization:))
      end
      let!(:other_component) { create(:component, manifest_name: "dummy", organization: other_organization) }
      let(:other_organization) { create(:organization) }

      it "returns the components belonging to the organization participatory spaces" do
        expect(subject).to include(component, assembly_component)
      end

      it "does not return components from other organizations" do
        expect(subject).not_to include(other_component)
      end

      it "does not load the organization participatory spaces into memory" do
        expect(organization).not_to receive(:participatory_spaces)

        subject.to_a
      end

      context "when a participatory space manifest already defines a projection" do
        let(:manifest) { Decidim.find_participatory_space_manifest(:participatory_processes) }
        let(:space_class) { manifest.model_class_name.constantize }

        before do
          allow(manifest).to receive(:participatory_spaces).and_return(
            ->(current_organization) { space_class.where(organization: current_organization).select(:id, :created_at) }
          )
        end

        it "only selects the id in the subquery" do
          expect(subject).to include(component)
        end
      end
    end

    describe "restricted_space?" do
      subject { component }

      let(:component) { create(:component, manifest_name: "another_dummy", participatory_space:) }

      context "when the component belongs to a restricted space" do
        let(:participatory_space) do
          create(:participatory_process, :restricted, organization:)
        end

        it "returns true" do
          expect(subject.restricted_space?).to be true
        end
      end

      context "when the component belongs to an open space" do
        let(:participatory_space) do
          create(:participatory_process, :open, organization:)
        end

        it "returns false" do
          expect(subject.restricted_space?).to be false
        end
      end

      context "when the component belongs to a transparent space" do
        let(:participatory_space) do
          create(:assembly, :transparent, organization:)
        end

        it "returns false" do
          expect(subject.restricted_space?).to be false
        end
      end
    end
  end
end
