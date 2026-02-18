# frozen_string_literal: true

require "spec_helper"

describe TranslatedEtiquetteValidator do
  subject { validatable.new(body:, current_organization:) }

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      def self.translatable_fields(*fields)
        @translatable_fields = fields
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :body
      attribute :current_organization

      translatable_fields :body

      validates :body, translated_etiquette: true

      # Add accessor for translated fields
      def body_en
        body[:en]
      end
    end
  end

  let(:current_organization) { create(:organization, default_locale: :en) }

  let(:body) { { en: "A SCREAMING BODY WITH TOO MANY CAPS" } }

  context "when Decidim.enable_etiquette_validator is false" do
    before do
      allow(Decidim).to receive(:enable_etiquette_validator).and_return(false)
    end

    it "skips validation for all translatable fields" do
      expect(subject).to be_valid
    end
  end

  context "when Decidim.enable_etiquette_validator is true" do
    before do
      allow(Decidim).to receive(:enable_etiquette_validator).and_return(true)
    end

    context "with invalid content" do
      it "performs validation on translatable fields" do
        expect(subject).not_to be_valid
        expect(subject.errors[:body_en]).not_to be_empty
      end
    end

    context "with valid content" do
      let(:body) { { en: "This is a reasonable body with proper capitalization" } }

      it "allows valid content" do
        expect(subject).to be_valid
      end
    end
  end
end
