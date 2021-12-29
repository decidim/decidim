# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::DiffChangesetCalculator do
  subject { described_class.new(changeset, fields_mapping, i18n_labels_scope).changeset }

  let(:date1) { 1.day.ago }
  let(:date2) { 1.hour.ago }
  let(:date3) { 1.day.from_now }
  let(:changeset) do
    {
      updated_at: [date1, date2],
      start_date: [date1, date3],
      title: ["Old title", "New title"]
    }
  end
  let(:fields_mapping) do
    {
      updated_at: :date,
      title: :string
    }
  end
  let(:i18n_labels_scope) { "activemodel.attributes.dummy_resource" }
  let(:title_attribute) do
    subject.find { |field| field[:attribute_name] == :title }
  end
  let(:attribute_names) { subject.pluck(:attribute_name) }

  describe "#changeset" do
    it "only keeps the fields in fields mapping" do
      expect(attribute_names).to match_array([:updated_at, :title])
    end

    it "generates the correct structure for the fields" do
      expect(title_attribute.keys).to match_array([:attribute_name, :label, :previous_value, :new_value, :type])
      expect(title_attribute[:attribute_name]).to eq :title
      expect(title_attribute[:previous_value]).to eq "Old title"
      expect(title_attribute[:new_value]).to eq "New title"
      expect(title_attribute[:label]).to eq "Title"
      expect(title_attribute[:type]).to eq :string
    end

    context "when changeset has the same values" do
      let(:changeset) do
        {
          updated_at: [date1, date1]
        }
      end

      it "skips the attribute" do
        expect(subject).to be_empty
      end
    end

    context "with i18n fields" do
      let(:changeset) do
        {
          field: [
            { "en" => "Foo", "ca" => "Bar" },
            { "en" => "Doe", "ca" => "Bar" }
          ]
        }
      end
      let(:fields_mapping) do
        {
          field: :i18n
        }
      end

      it "only returns those locales that changed" do
        expect(subject).to eq [
          {
            attribute_name: :field,
            label: "My field (English)",
            previous_value: "Foo",
            new_value: "Doe",
            type: :i18n
          }
        ]
      end

      context "when adding and deleting locales" do
        let(:changeset) do
          {
            field: [
              { "en" => "Foo" },
              { "ca" => "Bar" }
            ]
          }
        end

        it "calculates the diff correctly" do
          expect(subject.count).to eq 2
          expect(subject.first).to include(label: "My field (English)", previous_value: "Foo", new_value: nil)
          expect(subject.last).to include(label: "My field (Català)", previous_value: nil, new_value: "Bar")
        end

        context "when a changeset has an unexisting locale" do
          let(:changeset) do
            {
              field: [
                { "en" => "Foo", "zn" => "Bar" },
                { "en" => "Doe", "zn" => "Doe" }
              ]
            }
          end

          it "doesn't try to generate a nice label" do
            expect(subject.count).to eq 2
            expect(subject.first).to include(label: "My field (English)", previous_value: "Foo", new_value: "Doe")
            expect(subject.last).to include(label: "My field (zn)", previous_value: "Bar", new_value: "Doe")
          end
        end
      end

      context "when i18n labels scope is not set" do
        let(:i18n_labels_scope) { nil }

        it "humanizes the attribute name and keeps the locale" do
          expect(subject).to eq [
            {
              attribute_name: :field,
              label: "Field (English)",
              previous_value: "Foo",
              new_value: "Doe",
              type: :i18n
            }
          ]
        end
      end

      context "when the i18n values are strings" do
        let(:changeset) do
          {
            field: %w(Foo Bar)
          }
        end

        it "calculates the changeset for the default locale" do
          expect(subject).to eq [
            {
              attribute_name: :field,
              label: "My field (English)",
              previous_value: "Foo",
              new_value: "Bar",
              type: :i18n
            }
          ]
        end
      end

      context "when the i18n values are JSON formatted strings" do
        let(:changeset) do
          {
            field: [
              '"Foo"',
              '"Bar"'
            ]
          }
        end

        it "calculates the changeset for the default locale" do
          expect(subject).to eq [
            {
              attribute_name: :field,
              label: "My field (English)",
              previous_value: "Foo",
              new_value: "Bar",
              type: :i18n
            }
          ]
        end
      end

      context "when the i18n values are symbols" do
        let(:changeset) do
          {
            field: [
              :foo,
              :bar
            ]
          }
        end

        it "calculates the changeset for the default locale" do
          expect(subject).to eq [
            {
              attribute_name: :field,
              label: "My field (English)",
              previous_value: :foo,
              new_value: :bar,
              type: :i18n
            }
          ]
        end
      end
    end

    context "when fields mapping is empty" do
      let(:fields_mapping) { {} }

      it "renders nothing" do
        expect(subject).to be_empty
      end
    end

    context "when fields mapping is nil" do
      let(:fields_mapping) { nil }

      it "renders nothing" do
        expect(attribute_names).to match_array([:start_date, :title, :updated_at])
      end
    end
  end
end
