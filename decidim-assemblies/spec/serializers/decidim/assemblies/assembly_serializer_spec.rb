# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe AssemblySerializer do
    let(:resource) { create(:assembly) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the assembly data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(serialized).to include(id: resource.id)
        expect(serialized).to include(slug: resource.slug)
        expect(serialized).to include(title: resource.title)
        expect(serialized).to include(subtitle: resource.subtitle)
        expect(serialized).to include(weight: resource.weight)
        expect(serialized).to include(short_description: resource.short_description)
        expect(serialized).to include(description: resource.description)
        expect(serialized[:remote_hero_image_url]).to be_blob_url(resource.hero_image.blob)
        expect(serialized[:remote_banner_image_url]).to be_blob_url(resource.banner_image.blob)
        expect(serialized).to include(promoted: resource.promoted)
        expect(serialized).to include(developer_group: resource.developer_group)
        expect(serialized).to include(meta_scope: resource.meta_scope)
        expect(serialized).to include(local_area: resource.local_area)
        expect(serialized).to include(target: resource.target)
        expect(serialized).to include(decidim_scope_id: resource.decidim_scope_id)
        expect(serialized).to include(participatory_scope: resource.participatory_scope)
        expect(serialized).to include(participatory_structure: resource.participatory_structure)
        expect(serialized).to include(scopes_enabled: resource.scopes_enabled)
        expect(serialized).to include(private_space: resource.private_space)
        expect(serialized).to include(reference: resource.reference)
        expect(serialized).to include(purpose_of_action: resource.purpose_of_action)
        expect(serialized).to include(composition: resource.composition)
        expect(serialized).to include(duration: resource.duration)
        expect(serialized).to include(participatory_scope: resource.participatory_scope)
        expect(serialized).to include(included_at: resource.included_at)
        expect(serialized).to include(closing_date: resource.closing_date)
        expect(serialized).to include(created_by: resource.created_by)
        expect(serialized).to include(creation_date: resource.creation_date)
        expect(serialized).to include(closing_date_reason: resource.closing_date_reason)
        expect(serialized).to include(internal_organisation: resource.internal_organisation)
        expect(serialized).to include(is_transparent: resource.is_transparent)
        expect(serialized).to include(special_features: resource.special_features)
        expect(serialized).to include(twitter_handler: resource.twitter_handler)
        expect(serialized).to include(instagram_handler: resource.instagram_handler)
        expect(serialized).to include(facebook_handler: resource.facebook_handler)
        expect(serialized).to include(youtube_handler: resource.youtube_handler)
        expect(serialized).to include(github_handler: resource.github_handler)
        expect(serialized).to include(created_by_other: resource.created_by_other)
        expect(serialized).to include(announcement: resource.announcement)
      end

      context "when assembly has area" do
        let(:area) { create(:area, organization: resource.organization) }

        before do
          resource.area = area
          resource.save
        end

        it "includes the area" do
          serialized_area = subject.serialize[:area]

          expect(serialized_area).to be_a(Hash)

          expect(serialized_area).to include(id: resource.area.id)
          expect(serialized_area).to include(name: resource.area.name)
        end
      end

      context "when assembly has scope" do
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

      context "when assembly has type" do
        let(:assembly_type) { create(:assemblies_type, organization: resource.organization) }

        before do
          resource.assembly_type = assembly_type
          resource.save
        end

        it "includes the assembly type" do
          serialized_assembly_type = subject.serialize[:assembly_type]

          expect(serialized_assembly_type).to be_a(Hash)

          expect(serialized_assembly_type).to include(id: resource.assembly_type.id)
          expect(serialized_assembly_type).to include(title: resource.assembly_type.title)
        end
      end

      context "when assembly has categories" do
        let!(:category) { create(:category, participatory_space: resource) }

        it "includes the categories" do
          serialized_assembly_categories = subject.serialize[:categories].first
          expect(serialized_assembly_categories).to be_a(Hash)

          expect(serialized_assembly_categories).to include(id: category.id)
          expect(serialized_assembly_categories).to include(name: category.name)
          expect(serialized_assembly_categories).to include(description: category.description)
          expect(serialized_assembly_categories).to include(parent_id: category.parent_id)
        end

        context "when category has subcategories" do
          let!(:subcategory) { create(:subcategory, parent: category, participatory_space: resource) }

          it "includes the categories" do
            serialized_assembly_categories = subject.serialize[:categories].first

            expect(serialized_assembly_categories).to be_a(Hash)

            expect(serialized_assembly_categories).to include(id: category.id)
            expect(serialized_assembly_categories).to include(name: category.name)
            expect(serialized_assembly_categories).to include(description: category.description)
            expect(serialized_assembly_categories).to include(parent_id: category.parent_id)
          end
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

      context "when assembly has attachments" do
        let!(:attachment_collection) { create(:attachment_collection, collection_for: resource) }
        let!(:attachment) { create(:attachment, attached_to: resource, attachment_collection:) }

        it "includes the attachment" do
          serialized_assembly_attachment = subject.serialize[:attachments][:files].first

          expect(serialized_assembly_attachment).to be_a(Hash)

          expect(serialized_assembly_attachment).to include(id: attachment.id)
          expect(serialized_assembly_attachment).to include(title: attachment.title)
          expect(serialized_assembly_attachment).to include(weight: attachment.weight)
          expect(serialized_assembly_attachment).to include(description: attachment.description)
          expect(serialized_assembly_attachment[:remote_file_url]).to be_blob_url(resource.attachments.first.file.blob)
        end
      end
    end
  end
end
