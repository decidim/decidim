# frozen_string_literal: true

require "spec_helper"

module Decidim::Importers
  describe ParticipatorySpaceComponentsImporter do
    describe "#serialize" do
      subject do
        described_class.import(json_as_text)
      end

      let(:json_as_text) do
        <<-EOJSON
{}
EOJSON
      end
      let!(:component_1) { create(:component, name: :one) }
      let!(:participatory_space) { component_1.participatory_space }
      let!(:component_2) { create(:component, name: :two, participatory_space: participatory_space) }

      describe "#import" do
        let(:imported) { subject }

        it "imports space components" do
          expect(imported_from(component_1)).to eq(component_1)
          expect(imported_from(component_2)).to eq(component_1)
        end

        # Find the Decidim::Component created during importation that corresponds
        # to the +component+ used to generate the impoted json.
        def imported_from(component)
          imported= Decidim::Component.find_by(manifest_name: component.manifest_name, name: component.name)
          expect(imported).not_to be(nil)
          imported
        end
      end
    end
  end
end
