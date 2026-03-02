# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    describe "Initiative export collection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :admin, :confirmed, organization:) }
      let(:initiative) { create(:initiative, organization:) }
      let(:export_manifest) { initiative.manifest.export_manifests.find { |m| m.name == :initiatives } }

      describe "with unpublished initiatives" do
        let!(:unpublished_initiative) { create(:initiative, :created, organization:) }

        context "when user is an admin" do
          it "includes unpublished initiatives" do
            collection = export_manifest.collection.call(unpublished_initiative, admin)
            expect(collection).to include(unpublished_initiative)
          end
        end

        context "when user is nil (open data)" do
          it "excludes unpublished initiatives" do
            collection = export_manifest.collection.call(unpublished_initiative, nil)
            expect(collection).not_to include(unpublished_initiative)
          end
        end
      end

      describe "with published initiatives" do
        let!(:published_initiative) { create(:initiative, organization:) }

        it "includes published initiatives for admin" do
          collection = export_manifest.collection.call(published_initiative, admin)
          expect(collection).to include(published_initiative)
        end

        it "includes published initiatives for open data" do
          collection = export_manifest.collection.call(published_initiative, nil)
          expect(collection).to include(published_initiative)
        end
      end
    end
  end
end
