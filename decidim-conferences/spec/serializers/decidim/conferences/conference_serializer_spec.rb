# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceSerializer do
    let(:resource) { create(:conference) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the conference data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(serialized).to include(id: resource.id)
        expect(serialized).to include(slug: resource.slug)
        expect(serialized).to include(title: resource.title)
        expect(serialized).to include(slogan: resource.slogan)
        expect(serialized).to include(reference: resource.reference)
        expect(serialized).to include(weight: resource.weight)
        expect(serialized).to include(short_description: resource.short_description)
        expect(serialized).to include(description: resource.description)
        expect(serialized[:remote_hero_image_url]).to be_blob_url(resource.hero_image.blob)
        expect(serialized[:remote_banner_image_url]).to be_blob_url(resource.banner_image.blob)
        expect(serialized).to include(location: resource.location)
        expect(serialized).to include(promoted: resource.promoted)
        expect(serialized).to include(objectives: resource.objectives)
        expect(serialized).to include(start_date: resource.start_date)
        expect(serialized).to include(end_date: resource.end_date)
        expect(serialized).to include(scopes_enabled: resource.scopes_enabled)
        expect(serialized).to include(decidim_scope_id: resource.decidim_scope_id)
      end

      context "when conference has scope" do
        let(:scope) { create(:scope, organization: resource.organization) }

        before do
          resource.scope = scope
          resource.save
        end

        it "includes the scope" do
          serialized_scope = subject.serialize[:scope]

          expect(serialized_scope).to be_a(Hash)

          expect(serialized_scope).to include(id: resource.scope.id)
          expect(serialized_scope).to include(name: resource.scope.name)
        end
      end

      context "when assembly has taxonomies" do
        let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: resource.organization) }
        let(:serialized_taxonomies) do
          { ids: taxonomies.pluck(:id) }.merge(taxonomies.to_h { |t| [t.id, t.name] })
        end

        before do
          resource.update!(taxonomies:)
        end

        it "serializes the taxonomies" do
          expect(subject.serialize[:taxonomies]).to eq(serialized_taxonomies)
        end
      end

      context "when conference has categories" do
        let!(:category) { create(:category, participatory_space: resource) }

        it "includes the categories" do
          serialized_conference_categories = subject.serialize[:categories].first
          expect(serialized_conference_categories).to be_a(Hash)

          expect(serialized_conference_categories).to include(id: category.id)
          expect(serialized_conference_categories).to include(name: category.name)
          expect(serialized_conference_categories).to include(description: category.description)
          expect(serialized_conference_categories).to include(parent_id: category.parent_id)
        end

        context "when category has subcategories" do
          let!(:subcategory) { create(:subcategory, parent: category, participatory_space: resource) }

          it "includes the categories" do
            serialized_conference_categories = subject.serialize[:categories].first

            expect(serialized_conference_categories).to be_a(Hash)

            expect(serialized_conference_categories).to include(id: category.id)
            expect(serialized_conference_categories).to include(name: category.name)
            expect(serialized_conference_categories).to include(description: category.description)
            expect(serialized_conference_categories).to include(parent_id: category.parent_id)
          end
        end
      end

      context "when conference has attachments" do
        let!(:attachment_collection) { create(:attachment_collection, collection_for: resource) }
        let!(:attachment) { create(:attachment, attached_to: resource, attachment_collection:) }

        it "includes the attachment" do
          serialized_conference_attachments = subject.serialize[:attachments][:files].first

          expect(serialized_conference_attachments).to be_a(Hash)

          expect(serialized_conference_attachments).to include(id: attachment.id)
          expect(serialized_conference_attachments).to include(title: attachment.title)
          expect(serialized_conference_attachments).to include(weight: attachment.weight)
          expect(serialized_conference_attachments).to include(description: attachment.description)
          expect(serialized_conference_attachments[:remote_file_url]).to be_blob_url(resource.attachments.first.file.blob)
        end
      end
    end
  end
end
