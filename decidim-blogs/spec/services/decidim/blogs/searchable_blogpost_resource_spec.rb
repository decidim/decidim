# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    include_context "when a resource is ready for global search"

    let(:current_component) { create :post_component, organization: }

    let!(:resource) do
      create(
        :post,
        component: current_component,
        title: Decidim::Faker::Localized.name,
        body: description1
      )
    end

    describe "Indexing of resources" do
      context "when implementing Searchable" do
        context "when on create" do
          it "does indexes a SearchableResource after resource creation" do
            organization.available_locales.each do |locale|
              searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale:)
              expect_searchable_resource_to_correspond_to_post(searchable, resource, locale)
            end
          end
        end

        context "when on update" do
          context "when it is updated" do
            before do
              # rubocop:disable Rails/SkipsModelValidations
              resource.touch
              # rubocop:enable Rails/SkipsModelValidations
            end

            it "updates the associated SearchableResource after update" do
              searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id)
              created_at = searchable.created_at
              updated_title = Decidim::Faker::Localized.name.update("machine_translations" => {})
              resource.update(title: updated_title)

              resource.save!
              searchable.reload

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale:)
                expect(searchable.content_a).to eq I18n.transliterate(translated(updated_title, locale:).to_s)
                expect(searchable.updated_at).to be > created_at
              end
            end
          end
        end

        context "when on destroy" do
          it "destroys the associated SearchableResource after resource destroy" do
            resource.destroy
            searchables = SearchableResource.where(resource_type: resource.class.name, resource_id: resource.id)
            expect(searchables.any?).to be false
          end
        end
      end
    end

    describe "Search" do
      context "when searching by resource resource_type" do
        let!(:resource2) do
          create(
            :post,
            component: current_component,
            title: Decidim::Faker::Localized.name,
            body: Decidim::Faker::Localized.prefixed("Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!", test_locales)
          )
        end

        it "returns resource results" do
          Decidim::Search.call("Ow", organization, resource_type: resource.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[resource.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [resource, resource2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("wait", organization, resource_type: resource.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[resource.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [resource2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_post(searchable, resource, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(resource.created_at.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(resource, locale))
    end

    def expected_searchable_resource_attrs(resource, locale)
      {
        "content_a" => I18n.transliterate(translated(resource.title, locale:)),
        "content_b" => "",
        "content_c" => "",
        "content_d" => I18n.transliterate(translated(resource.body, locale:)),
        "locale" => locale,

        "decidim_organization_id" => resource.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => nil,
        "resource_id" => resource.id,
        "resource_type" => "Decidim::Blogs::Post"
      }
    end
  end
end
