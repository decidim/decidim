# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    describe "Assembly export collection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :admin, :confirmed, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      let(:export_manifest) { assembly.manifest.export_manifests.find { |m| m.name == :assemblies } }

      describe "with restricted assemblies" do
        let!(:restricted_assembly) { create(:assembly, :restricted, organization:) }

        context "when user is an admin" do
          it "includes restricted assemblies" do
            collection = export_manifest.collection.call(restricted_assembly, admin)
            expect(collection).to include(restricted_assembly)
          end
        end

        context "when user is nil (open data)" do
          it "excludes restricted assemblies" do
            collection = export_manifest.collection.call(restricted_assembly, nil)
            expect(collection).not_to include(restricted_assembly)
          end
        end
      end

      describe "with transparent assemblies" do
        let!(:transparent_assembly) { create(:assembly, :transparent, organization:) }

        context "when user is an admin" do
          it "includes transparent assemblies" do
            collection = export_manifest.collection.call(transparent_assembly, admin)
            expect(collection).to include(transparent_assembly)
          end
        end

        context "when user is nil (open data)" do
          it "includes transparent assemblies" do
            collection = export_manifest.collection.call(transparent_assembly, nil)
            expect(collection).to include(transparent_assembly)
          end
        end
      end

      describe "with unpublished assemblies" do
        let!(:unpublished_assembly) { create(:assembly, :unpublished, organization:) }

        context "when user is an admin" do
          it "includes unpublished assemblies" do
            collection = export_manifest.collection.call(unpublished_assembly, admin)
            expect(collection).to include(unpublished_assembly)
          end
        end

        context "when user is nil (open data)" do
          it "excludes unpublished assemblies" do
            collection = export_manifest.collection.call(unpublished_assembly, nil)
            expect(collection).not_to include(unpublished_assembly)
          end
        end
      end

      describe "with public published assemblies" do
        let!(:public_assembly) { create(:assembly, organization:) }

        it "includes public published assemblies for admin" do
          collection = export_manifest.collection.call(public_assembly, admin)
          expect(collection).to include(public_assembly)
        end

        it "includes public published assemblies for open data" do
          collection = export_manifest.collection.call(public_assembly, nil)
          expect(collection).to include(public_assembly)
        end
      end
    end
  end
end
