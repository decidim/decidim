# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OpenDataConferenceSerializer do
    let(:resource) { create(:conference) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the conference data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(serialized).to include(id: resource.id)
        expect(serialized).to include(slug: resource.slug)
        expect(serialized).to include(hashtag: resource.hashtag)
        expect(serialized).to include(title: resource.title)
        expect(serialized).to include(url: "http://#{resource.organization.host}:#{Capybara.server_port}/#{I18n.locale}/conferences/#{resource.slug}")
        expect(serialized).to include(slogan: resource.slogan)
        expect(serialized).to include(reference: resource.reference)
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
        expect(serialized).to include(created_at: resource.created_at)
        expect(serialized).to include(updated_at: resource.updated_at)
        expect(serialized).to include(published_at: resource.published_at)
        expect(serialized).to include(follows_count: resource.follows_count)
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
    end
  end
end
