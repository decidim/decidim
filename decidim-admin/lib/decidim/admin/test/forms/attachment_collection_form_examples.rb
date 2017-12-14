# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "attachment collection form" do
      let(:name) {
        {
          en: "My attachment collection",
          es: "Mi colección de adjuntos",
          ca: "La meva colecció d'adjunts"
        }
      }
      let(:description) {
        {
          en: "My attachment collection description",
          es: "Descripción de mi colección de adjuntos",
          ca: "Descripció de la meva colecció d'adjunts"
        }
      }

      let(:attributes) do
        {
          "attachment_collection" => {
            "name_en" => name[:en],
            "name_es" => name[:es],
            "name_ca" => name[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca]
          }
        }
      end
      let(:organization) { create :organization }

      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_participatory_space: participatory_space,
          current_organization: organization
        )
      end

      context "with correct data" do
        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when default language in name is missing" do
        let(:name) do
          {
            es: "Mi colección de adjuntos",
            ca: "La meva colecció d'adjunts"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in description is missing" do
        let(:description) do
          {
            ca: "Descripció de la meva colecció d'adjunts"
          }
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
