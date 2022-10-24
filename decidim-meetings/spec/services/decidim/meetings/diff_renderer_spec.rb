# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::DiffRenderer, versioning: true do
  let!(:meeting) { create :meeting }
  let!(:old_values) { meeting.attributes }
  let(:version) { meeting.versions.last }

  let!(:start_time) { 1.day.ago }
  let!(:end_time) { Time.zone.now }
  let!(:user_group) { create :user_group, organization: meeting.organization }
  let!(:scope) { create(:scope, organization: meeting.organization) }

  before do
    Decidim.traceability.update!(
      meeting,
      "Test suite",
      title: {
        en: "Only changes in English"
      },
      description: {
        ca: "<p>New HTML description</p>"
      },
      address: "Decidim Street",
      location: { ca: "Biblioteca", en: "Library" },
      location_hints: { ca: "Indicacions", en: "Hints" },
      start_time:,
      end_time:,
      decidim_user_group_id: user_group,
      decidim_scope_id: scope.id
    )
  end

  describe "#diff" do
    subject { described_class.new(version).diff }

    it "calculates the fields that have changed" do
      expect(subject.keys)
        .to match_array [:title_en, :description_ca, :address, :location_ca, :location_en, :location_hints_ca, :location_hints_en, :start_time, :end_time, :decidim_scope_id]
    end

    it "has the old and new values for each field" do
      expect(subject[:title_en][:old_value]).to eq old_values["title"]["en"]
      expect(subject[:title_en][:new_value]).to eq "Only changes in English"

      expect(subject[:description_ca][:old_value]).to eq old_values["description"]["ca"]
      expect(subject[:description_ca][:new_value]).to eq "<p>New HTML description</p>"

      expect(subject[:address][:old_value]).to eq old_values["address"]
      expect(subject[:address][:new_value]).to eq "Decidim Street"

      expect(subject[:location_ca][:old_value]).to eq old_values["location"]["ca"]
      expect(subject[:location_ca][:new_value]).to eq "Biblioteca"
      expect(subject[:location_en][:old_value]).to eq old_values["location"]["en"]
      expect(subject[:location_en][:new_value]).to eq "Library"

      expect(subject[:location_hints_ca][:old_value]).to eq old_values["location_hints"]["ca"]
      expect(subject[:location_hints_ca][:new_value]).to eq "Indicacions"
      expect(subject[:location_hints_en][:old_value]).to eq old_values["location_hints"]["en"]
      expect(subject[:location_hints_en][:new_value]).to eq "Hints"

      expect(subject[:start_time][:old_value]).to eq old_values["start_time"]
      expect(subject[:start_time][:new_value]).to eq start_time

      expect(subject[:end_time][:old_value]).to eq old_values["end_time"]
      expect(subject[:end_time][:new_value]).to eq end_time

      expect(subject[:decidim_user_group_id]).to be_nil

      expect(subject[:decidim_scope_id][:old_value]).to be_blank
      expect(subject[:decidim_scope_id][:new_value]).to eq translated(scope.name)
    end

    it "has the type of each field" do
      expected_types = {
        title_en: :i18n,
        description_ca: :i18n_html,
        address: :string,
        location_ca: :i18n,
        location_en: :i18n,
        location_hints_ca: :i18n,
        location_hints_en: :i18n,
        start_time: :date,
        end_time: :date,
        decidim_scope_id: :scope
      }
      types = subject.to_h { |attribute, data| [attribute.to_sym, data[:type]] }
      expect(types).to eq expected_types
    end

    it "generates the labels correctly" do
      expected_labels = {
        title_en: "Title (English)",
        description_ca: "Description (Català)",
        address: "Address",
        location_ca: "Location (Català)",
        location_en: "Location (English)",
        location_hints_ca: "Location hints (Català)",
        location_hints_en: "Location hints (English)",
        start_time: "Start Time",
        end_time: "End Time",
        decidim_scope_id: "Scope"
      }
      labels = subject.to_h { |attribute, data| [attribute.to_sym, data[:label]] }
      expect(labels).to eq expected_labels
    end

    context "when one of the locales is not available" do
      let!(:default_available_locales) do
        I18n.available_locales
      end

      before do
        I18n.available_locales = [:en]
      end

      after do
        I18n.available_locales = default_available_locales
      end

      it "generates the label with locale name" do
        expected_labels = {
          title_en: "Title (English)",
          description_ca: "Description (ca)",
          address: "Address",
          location_ca: "Location (ca)",
          location_en: "Location (English)",
          location_hints_ca: "Location hints (ca)",
          location_hints_en: "Location hints (English)",
          start_time: "Start Time",
          end_time: "End Time",
          decidim_scope_id: "Scope"
        }
        labels = subject.to_h { |attribute, data| [attribute.to_sym, data[:label]] }
        expect(labels).to eq expected_labels
      end
    end
  end
end
