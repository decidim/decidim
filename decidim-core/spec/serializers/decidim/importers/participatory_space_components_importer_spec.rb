# frozen_string_literal: true

require "spec_helper"

module Decidim::Importers
  describe ParticipatorySpaceComponentsImporter do
    describe "#serialize" do
      subject do
        described_class.from_json(json_as_text)
      end

      let!(:component_1) { create(:component, :published, :with_settings, :with_permissions, name: :one) }
      let!(:participatory_space) { component_1.participatory_space }
      let!(:component_2) { create(:component, :unpublished, :with_settings, :with_permissions, name: :two, participatory_space: participatory_space) }

      let(:json_as_text) do
        <<~EOJSON
          [{
            "manifest_name": "#{component_1.manifest_name}",
            "id": #{component_1.id},
            "name": {
              "ca": "#{component_1.name[:ca]}",
              "en": "#{component_1.name[:en]}",
              "es": "#{component_1.name[:es]}"
            },
            "participatory_space_id": #{component_1.participatory_space.id},
            "participatory_space_type": "#{component_1.participatory_space.class.name}",
            "settings": #{component_1.settings.to_json},
            "weight": #{component_1.weight},
            "permissions": #{component_1.permissions.to_json},
            "published_at": #{component_1.published_at}
          }, {
            "manifest_name": "#{component_2.manifest_name}",
            "id": #{component_2.id},
            "name": {
              "ca": "#{component_2.name[:ca]}",
              "en": "#{component_2.name[:en]}",
              "es": "#{component_2.name[:es]}"
            },
            "participatory_space_id": #{component_2.participatory_space.id},
            "participatory_space_type": "#{component_2.participatory_space.class.name}",
            "settings": #{component_2.settings.to_json},
            "weight": #{component_2.weight},
            "permissions": #{component_2.permissions.to_json},
            "published_at": #{component_2.published_at}
          }
          ]
        EOJSON
      end

      describe "#import" do
        let(:imported) { subject }

        it "imports space components" do
          expect(imported_from(component_1)).to eq(component_1)
          expect(imported_from(component_2)).to eq(component_2)
        end

        # Find the Decidim::Component created during importation that corresponds
        # to the +component+ used to generate the impoted json.
        def imported_from(component)
          imported = Decidim::Component.find_by(manifest_name: component.manifest_name, name: component.name)
          expect(imported).not_to be(nil)
          imported
        end
      end
    end
  end
end
