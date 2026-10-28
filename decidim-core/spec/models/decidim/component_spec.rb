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

    describe "reciprocal associations" do
      subject(:component) { create(:component, manifest_name: "dummy", organization:) }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:other_component) { create(:component, manifest_name: "dummy", organization: other_organization) }

      shared_examples "component reciprocal association" do |association, owner|
        before do
          record
          other_record
        end

        it "only includes the records of its own component" do
          expect(component.public_send(association)).to contain_exactly(record)
        end

        it "does not include the records of another component, even when it is in another organization" do
          expect(component.public_send(association)).not_to include(other_record)
        end

        it "points back to the component from the records loaded through the association" do
          expect(component.public_send(association).first.public_send(owner)).to eq(component)
        end

        it "deletes the records when the component is destroyed" do
          component.destroy

          expect(record.class.where(id: record.id)).to be_empty
          expect(other_record.class.where(id: other_record.id)).to exist
        end
      end

      context "with action logs" do
        let(:record) { create(:action_log, organization:, component:, user: create(:user, organization:)) }
        let(:other_record) { create(:action_log, organization: other_organization, component: other_component, user: create(:user, organization: other_organization)) }

        it_behaves_like "component reciprocal association", :action_logs, :component
      end

      context "with reminders" do
        let(:record) { create(:reminder, user: create(:user, organization:), component:) }
        let(:other_record) { create(:reminder, user: create(:user, organization: other_organization), component: other_component) }

        it_behaves_like "component reciprocal association", :reminders, :component
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
