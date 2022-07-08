# frozen_string_literal: true

require "spec_helper"

module Decidim::Importers
  describe ParticipatorySpaceComponentsImporter do
    describe "#serialize" do
      subject do
        described_class.new(participatory_space).from_json(json_as_text, user)
      end

      let(:user) { create(:user) }
      let(:previous_participatory_space) { create(:participatory_process) }
      let!(:component1) { create(:component, :with_one_step, :published, :with_permissions, weight: 1) }
      let!(:participatory_space) { component1.participatory_space }
      let!(:component2) { create(:component, :with_one_step, :unpublished, :with_permissions, participatory_space: participatory_space, weight: 2) }

      let(:json_as_text) do
        <<~EOJSON
          [{
            "manifest_name": "#{component1.manifest_name}",
            "id": #{component1.id},
            "name": {
              "ca": "#{component1.name["ca"]}",
              "en": "#{component1.name["en"]}",
              "es": "#{component1.name["es"]}"
            },
            "participatory_space_id": #{previous_participatory_space.id},
            "participatory_space_type": "#{component1.participatory_space.class.name}",
            "settings": #{component1.attributes["settings"].to_json},
            "weight": #{component1.weight},
            "permissions": #{component1.permissions.to_json},
            "published_at": "#{component1.published_at&.iso8601 || "null"}"
          }, {
            "manifest_name": "#{component2.manifest_name}",
            "id": #{component2.id},
            "name": {
              "ca": "#{component2.name["ca"]}",
              "en": "#{component2.name["en"]}",
              "es": "#{component2.name["es"]}"
            },
            "participatory_space_id": #{previous_participatory_space.id},
            "participatory_space_type": "#{component2.participatory_space.class.name}",
            "settings": #{component2.attributes["settings"].to_json},
            "weight": #{component2.weight},
            "permissions": #{component2.permissions.to_json},
            "published_at": "#{component2.published_at&.iso8601 || "null"}"
          }
          ]
        EOJSON
      end

      describe "#import" do
        let!(:imported) { subject }

        it "imports space components" do
          expect_imported_to_be_equal(component1)
          expect_imported_to_be_equal(component2)
        end

        def expect_imported_to_be_equal(component)
          actual_attrs = imported_from(component).attributes.except("id", "updated_at", "created_at", "name")
          imported_name = imported_from(component).attributes["name"]
          actual_attrs.merge!("name" => imported_name.except("machine_translations", "es"))

          expected_attrs = component.attributes.except("id", "updated_at", "created_at", "name")
          expected_name = component.attributes["name"]
          expected_attrs.merge!("name" => expected_name.except("machine_translations", "es"))

          actual_published_at = actual_attrs.delete("published_at")
          expected_published_at = expected_attrs.delete("published_at")

          expect(actual_published_at).to be_within(1.second).of(expected_published_at) unless actual_published_at.nil? && expected_published_at.nil?
          expect(actual_attrs).to eq(expected_attrs)
        end

        # Find the Decidim::Component created during importation that corresponds
        # to the +component+ used to generate the impoted json.
        def imported_from(component)
          imported = Decidim::Component.where.not(id: component.id)
                                       .find_by(manifest_name: component.manifest_name, weight: component.weight)
          expect(imported).to be_present
          imported
        end
      end
    end
  end
end
