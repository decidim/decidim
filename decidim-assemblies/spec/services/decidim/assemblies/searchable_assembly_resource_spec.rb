# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:author) { create(:user, :admin) }
    let(:organization) { author.organization }
    let(:scope1) { create :scope, organization: organization }
    let!(:assembly) do
      create(
        :assembly,
        :unpublished,
        organization: organization,
        scope: scope1,
        title: "Nulla TestCheck accumsan tincidunt.",
        subtitle: "Nulla TestCheck accumsan tincidunt description Ow!",
        short_description: "Nulla TestCheck accumsan tincidunt description Ow!",
        description: "Nulla TestCheck accumsan tincidunt description Ow!",
        users: [author]
      )
    end

    describe "Indexing of assemblies" do
      context "when implementing Searchable" do
        context "when on create" do
          context "when assemblies are created" do
            it "does not index a SearchableResource after Assembly creation" do
              searchables = SearchableResource.where(resource_type: assembly.class.name, resource_id: assembly.id)
              expect(searchables).to be_empty
            end
          end

          context "when assemblies ARE private" do
            before do
              assembly.update(published_at: Time.current, private_space: true)
            end

            it "does indexes a SearchableResource after Assembly creation when it is not private_space" do
              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: assembly.class.name, resource_id: assembly.id, locale: locale)
                expect_searchable_resource_to_correspond_to_assembly(searchable, assembly, locale)
              end
            end
          end
        end

        context "when on update" do
          context "when it is NOT published" do
            it "does not index a SearchableResource when Assembly changes but is not published" do
              searchables = SearchableResource.where(resource_type: assembly.class.name, resource_id: assembly.id)
              expect(searchables).to be_empty
            end
          end

          context "when it IS published" do
            before do
              assembly.update published_at: Time.current
            end

            it "inserts a SearchableResource after Assembly is published" do
              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: assembly.class.name, resource_id: assembly.id, locale: locale)
                expect_searchable_resource_to_correspond_to_assembly(searchable, assembly, locale)
              end
            end

            it "updates the associated SearchableResource after published Assembly update" do
              searchable = SearchableResource.find_by(resource_type: assembly.class.name, resource_id: assembly.id)
              created_at = searchable.created_at
              updated_title = "Brand new title"
              assembly.update(title: updated_title)

              assembly.save!
              searchable.reload

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: assembly.class.name, resource_id: assembly.id, locale: locale)
                expect(searchable.content_a).to eq updated_title
                expect(searchable.updated_at).to be > created_at
              end
            end

            it "removes tha associated SearchableResource after unpublishing a published Assembly on update" do
              assembly.update(published_at: nil)

              searchables = SearchableResource.where(resource_type: assembly.class.name, resource_id: assembly.id)
              expect(searchables).to be_empty
            end
          end
        end

        context "when on destroy" do
          it "destroys the associated SearchableResource after Assembly destroy" do
            assembly.destroy

            searchables = SearchableResource.where(resource_type: assembly.class.name, resource_id: assembly.id)

            expect(searchables.any?).to be false
          end
        end
      end
    end

    describe "Search" do
      context "when searching by Assembly resource_type" do
        let!(:assembly2) do
          create(
            :assembly,
            organization: organization,
            scope: scope1,
            title: Decidim::Faker.name,
            subtitle: Decidim::Faker.name,
            short_description: "Giving a signal...",
            description: "Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!",
            users: [author]
          )
        end

        before do
          assembly.update(published_at: Time.current)
          assembly2.update(published_at: Time.current)
        end

        it "returns Assembly results" do
          Decidim::Search.call("Ow", organization, resource_type: assembly.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[assembly.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [assembly, assembly2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("wait", organization, resource_type: assembly.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[assembly.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [assembly2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_assembly(searchable, assembly, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(assembly.published_at.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(assembly, locale))
    end

    def expected_searchable_resource_attrs(assembly, locale)
      {
        "content_a" => assembly.title,
        "content_b" => assembly.subtitle,
        "content_c" => assembly.short_description,
        "content_d" => assembly.description,
        "locale" => locale,

        "decidim_organization_id" => assembly.organization.id,
        "decidim_participatory_space_id" => assembly.id,
        "decidim_participatory_space_type" => assembly.class.name,
        "decidim_scope_id" => assembly.decidim_scope_id,
        "resource_id" => assembly.id,
        "resource_type" => assembly.class.name
      }
    end
  end
end
