# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssembliesTypeForm do
        subject { described_class.from_params(attributes) }

        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:attributes) do
          {
            "assemblies_type" => {
              "title" => title
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when title is missing" do
          let(:title) {}

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
