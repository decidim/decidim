# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    include_context "when a resource is ready for global search"

    let(:current_component) { create(:collaborative_texts_component, organization:) }

    let!(:resource) do
      create(
        :collaborative_text_document,
        :published,
        component: current_component,
        title: "A basic collaborative text! Ow!",
        body: "A basic collaborative body!"
      )
    end

    describe "Indexing of resources" do
      context "when implementing Searchable" do
        context "when on create" do
          it "does indexes a SearchableResource after resource creation" do
            organization.available_locales.each do |locale|
              searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale:)
              expect_searchable_resource_to_correspond_to_collaborative_text_document(searchable, resource, locale)
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
              updated_title = ::Faker::Lorem.sentence(word_count: 3)
              resource.update(title: updated_title)

              resource.save!
              searchable.reload

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale:)
                expect(searchable.content_a).to eq updated_title
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
      context "when searching by Collaborative texts Document resource_type" do
        let!(:resource2) do
          create(
            :collaborative_text_document,
            :published,
            component: current_component,
            title: "Waiting for the sun!",
            body: "The sun is shining, the weather is sweet! Ow!"
          )
        end
        let!(:draft_version) { create(:collaborative_text_version, :draft, document: resource2) }

        it "returns resource results" do
          Decidim::Search.call("Ow", organization, resource_type: resource.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[resource.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to contain_exactly(resource, resource2)
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

    def expect_searchable_resource_to_correspond_to_collaborative_text_document(searchable, resource, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_fs(:short)).to eq(resource.published_at.to_fs(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(resource, locale))
    end

    def expected_searchable_resource_attrs(resource, locale)
      {
        "content_a" => I18n.transliterate(resource.title),
        "content_b" => "",
        "content_c" => "",
        "content_d" => I18n.transliterate(resource.consolidated_body),
        "locale" => locale,

        "decidim_organization_id" => resource.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => nil,
        "resource_id" => resource.id,
        "resource_type" => "Decidim::CollaborativeTexts::Document"
      }
    end
  end
end
