# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    describe "Conference export collection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :admin, :confirmed, organization:) }
      let(:conference) { create(:conference, organization:) }
      let(:export_manifest) { conference.manifest.export_manifests.find { |m| m.name == :conferences } }

      describe "with unpublished conferences" do
        let!(:unpublished_conference) { create(:conference, :unpublished, organization:) }

        context "when user is an admin" do
          it "includes unpublished conferences" do
            collection = export_manifest.collection.call(unpublished_conference, admin)
            expect(collection).to include(unpublished_conference)
          end
        end

        context "when user is nil (open data)" do
          it "excludes unpublished conferences" do
            collection = export_manifest.collection.call(unpublished_conference, nil)
            expect(collection).not_to include(unpublished_conference)
          end
        end
      end

      describe "with published conferences" do
        let!(:published_conference) { create(:conference, organization:) }

        it "includes published conferences for admin" do
          collection = export_manifest.collection.call(published_conference, admin)
          expect(collection).to include(published_conference)
        end

        it "includes published conferences for open data" do
          collection = export_manifest.collection.call(published_conference, nil)
          expect(collection).to include(published_conference)
        end
      end
    end
  end
end
