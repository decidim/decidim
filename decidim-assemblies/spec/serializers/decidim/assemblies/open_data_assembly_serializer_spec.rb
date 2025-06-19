# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe OpenDataAssemblySerializer do
    let(:resource) { create(:assembly) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the assembly data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(serialized).to include(id: resource.id)
        expect(serialized).to include(reference: resource.reference)
        expect(serialized).to include(slug: resource.slug)
        expect(serialized).to include(title: resource.title)
        expect(serialized).to include(url: "http://#{resource.organization.host}:#{Capybara.server_port}/assemblies/#{resource.slug}")
        expect(serialized).to include(subtitle: resource.subtitle)
        expect(serialized).to include(short_description: resource.short_description)
        expect(serialized).to include(description: resource.description)
        expect(serialized[:remote_hero_image_url]).to be_blob_url(resource.hero_image.blob)
        expect(serialized[:remote_banner_image_url]).to be_blob_url(resource.banner_image.blob)
        expect(serialized).to include(promoted: resource.promoted)
        expect(serialized).to include(developer_group: resource.developer_group)
        expect(serialized).to include(meta_scope: resource.meta_scope)
        expect(serialized).to include(local_area: resource.local_area)
        expect(serialized).to include(target: resource.target)
        expect(serialized).to include(created_at: resource.created_at)
        expect(serialized).to include(updated_at: resource.updated_at)
        expect(serialized).to include(published_at: resource.published_at)
        expect(serialized).to include(follows_count: resource.follows_count)
        expect(serialized).to include(decidim_scope_id: resource.decidim_scope_id)
        expect(serialized).to include(participatory_scope: resource.participatory_scope)
        expect(serialized).to include(participatory_structure: resource.participatory_structure)
        expect(serialized).to include(scopes_enabled: resource.scopes_enabled)
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
    end
  end
end
