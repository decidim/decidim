# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    describe "Assembly export collection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :admin, :confirmed, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      let(:export_manifest) { assembly.manifest.export_manifests.find { |m| m.name == :assemblies } }

      describe "with private non-transparent assemblies" do
        let!(:private_assembly) { create(:assembly, :private, :opaque, organization:) }

        context "when user is an admin" do
          it "includes private non-transparent assemblies" do
            collection = export_manifest.collection.call(private_assembly, admin)
            expect(collection).to include(private_assembly)
          end
        end

        context "when user is nil (open data)" do
          it "excludes private non-transparent assemblies" do
            collection = export_manifest.collection.call(private_assembly, nil)
            expect(collection).not_to include(private_assembly)
          end
        end
      end

      describe "with private transparent assemblies" do
        let!(:transparent_assembly) { create(:assembly, :private, :transparent, organization:) }

        context "when user is an admin" do
          it "includes private transparent assemblies" do
            collection = export_manifest.collection.call(transparent_assembly, admin)
            expect(collection).to include(transparent_assembly)
          end
        end

        context "when user is nil (open data)" do
          it "includes private transparent assemblies" do
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
