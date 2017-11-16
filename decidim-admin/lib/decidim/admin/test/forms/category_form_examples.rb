# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "category form" do
      let(:name) do
        {
          en: "Name",
          es: "Nombre",
          ca: "Nom"
        }
      end
      let(:description) do
        {
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:parent_id) { nil }
      let(:attributes) do
        {
          "category" => {
            "name_en" => name[:en],
            "name_es" => name[:es],
            "name_ca" => name[:ca],
            "parent_id" => parent_id,
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

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when default language in name is missing" do
        let(:name) do
          {
            ca: "Nom",
            es: "Nombre"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in description is missing" do
        let(:description) do
          {
            ca: "Descripció"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when the parent_id is set" do
        let!(:category) { create :category, participatory_space: participatory_space }

        context "to the ID of a first-class category" do
          let(:parent_id) { category.id }

          it { is_expected.to be_valid }
        end

        context "to the ID of a subcategory" do
          let!(:subcategory) { create :subcategory, parent: category }
          let(:parent_id) { subcategory.id }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
