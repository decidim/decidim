# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatablePresenceValidator do
    let(:record) do
      Class.new(Decidim::Form) do
        include TranslatableAttributes
        mimic :participatory_process
        attribute :current_organization, Decidim::Organization
        translatable_attribute :description, String
      end.from_params({ participatory_process: { description: description } }, current_organization: organization)
    end
    let(:organization) { build(:organization, available_locales: available_locales) }
    let(:available_locales) { %w(en ca) }
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
    subject { described_class.new(options).validate_each(record, attribute, nil) }

    context "when all translations are present" do
      it "validates the record" do
        subject
        expect(record).to be_valid
      end
    end

    context "when some translations are missing" do
      let(:description) do
        {
          en: "Description"
        }
      end

      it "does not validate the record" do
        subject
        expect(record.errors).not_to be_empty
        expect(record.errors[:description_ca]).to eq ["can't be blank"]
      end
    end
  end
end
