# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatablePresenceValidator do
    subject { described_class.new(options).validate_each(record, attribute, nil) }

    let(:record) do
      Class.new(Decidim::Form) do
        include TranslatableAttributes
        mimic :participatory_process
        attribute :current_organization, Decidim::Organization
        translatable_attribute :description, String
      end.from_params({ participatory_process: { description: description } }, current_organization: organization)
    end
    let(:organization) do
      build(
        :organization,
        available_locales: available_locales,
        default_locale: default_locale
      )
    end
    let(:available_locales) { %w(en ca) }
    let(:default_locale) { :en }
    let(:description) do
      {
        ca: "Descripció",
        en: "Description"
      }
    end
    let(:attribute) { :description }
    let(:options) do
      {
        attributes: [attribute]
      }
    end

    context "when all translations are present" do
      it "validates the record" do
        subject
        expect(record).to be_valid
      end
    end

    context "when only default translation is present" do
      let(:description) do
        {
          en: "Description"
        }
      end

      it "validates the record" do
        subject
        expect(record).to be_valid
      end
    end

    context "when default translation is missing" do
      let(:description) do
        {
          ca: "Descripció"
        }
      end

      it "does not validate the record" do
        subject
        expect(record.errors).not_to be_empty
        expect(record.errors[:description_en]).to eq ["can't be blank"]
      end
    end

    context "when translation name is hyphenated" do
      let(:available_locales) { ["en", "ca", "es-MX"] }
      let(:default_locale) { :"es-MX" }
      let(:description) do
        {
          "es-MX": "Descripción"
        }
      end

      before { allow(Decidim).to receive(:available_locales).and_return(available_locales) }

      it "validates the record" do
        subject
        expect(record).to be_valid
      end
    end

    context "when organization is blank" do
      let(:organization) { nil }

      it "does not validate the record" do
        subject
        expect(record.errors).not_to be_empty
        expect(record.errors[:current_organization]).to eq ["can't be blank"]
      end
    end
  end
end
