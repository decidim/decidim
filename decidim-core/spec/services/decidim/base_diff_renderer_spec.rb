# frozen_string_literal: true

require "spec_helper"

describe Decidim::BaseDiffRenderer, versioning: true do
  let(:diff_renderer) { described_class.new(version) }
  let(:version) { resource.versions.last }
  let(:resource) { create(:dummy_resource) }

  shared_examples "parsing a version changeset for a given attribute" do
    it "calculates the fields that have changed" do
      expect(subject.keys).to include(field_name)
    end

    it "has the old and new values for each field" do
      expect(subject[field_name][:old_value]).to eq(old_value)
      expect(subject[field_name][:new_value]).to eq(new_value)
    end

    it "has the type of each field" do
      expect(subject[field_name]).to include(type: field_type)
    end

    it "generates the labels correctly" do
      expect(subject[field_name]).to include(label: field_label)
    end
  end

  describe "#diff" do
    subject { diff_renderer.diff }

    it "raises an error" do
      expect { subject }.to raise_error(StandardError, "Not implemented")
    end

    context "when an attribute_type is matched" do
      before { allow(diff_renderer).to receive(:attribute_types).and_return(title: :string) }

      it_behaves_like "parsing a version changeset for a given attribute" do
        let(:field_name) { :title }
        let(:field_type) { :string }
        let(:field_label) { "Title" }
        let(:old_value) { nil }
        let(:new_value) { resource.title }
      end
    end

    context "when a :i18n attribute_type is matched" do
      before do
        resource.update(translatable_text: { ca: "Catalan text" })
        allow(diff_renderer).to receive(:attribute_types).and_return(translatable_text: :i18n)
      end

      it_behaves_like "parsing a version changeset for a given attribute" do
        let(:field_name) { :translatable_text_ca }
        let(:field_type) { :i18n }
        let(:field_label) { "Translatable text (Català)" }
        let(:old_value) { nil }
        let(:new_value) { resource.translatable_text["ca"] }
      end

      context "when one of the locales is not available" do
        let!(:available_locales) { I18n.available_locales }

        before { I18n.available_locales = [:en] }

        after { I18n.available_locales = available_locales }

        it "generates the label with locale name" do
          expect(subject[:translatable_text_ca]).to include(label: "Translatable text (ca)")
        end
      end
    end
  end
end
