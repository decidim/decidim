# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    describe "Participatory Process export collection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :admin, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:export_manifest) { participatory_process.manifest.export_manifests.find { |m| m.name == :participatory_processes } }

      describe "with private processes" do
        let!(:private_process) { create(:participatory_process, :private, organization:) }

        context "when user is an admin" do
          it "includes private processes" do
            collection = export_manifest.collection.call(private_process, admin)
            expect(collection).to include(private_process)
          end
        end

        context "when user is nil (open data)" do
          it "excludes private processes" do
            collection = export_manifest.collection.call(private_process, nil)
            expect(collection).not_to include(private_process)
          end
        end
      end

      describe "with unpublished processes" do
        let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:) }

        context "when user is an admin" do
          it "includes unpublished processes" do
            collection = export_manifest.collection.call(unpublished_process, admin)
            expect(collection).to include(unpublished_process)
          end
        end

        context "when user is nil (open data)" do
          it "excludes unpublished processes" do
            collection = export_manifest.collection.call(unpublished_process, nil)
            expect(collection).not_to include(unpublished_process)
          end
        end
      end

      describe "with public published processes" do
        let!(:public_process) { create(:participatory_process, organization:) }

        it "includes public published processes for admin" do
          collection = export_manifest.collection.call(public_process, admin)
          expect(collection).to include(public_process)
        end

        it "includes public published processes for open data" do
          collection = export_manifest.collection.call(public_process, nil)
          expect(collection).to include(public_process)
        end
      end
    end
  end
end
