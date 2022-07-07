# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    include_context "when a resource is ready for global search"

    let(:current_component) { create :budgets_component, organization: organization }
    let(:budget) { create :budget, component: current_component }

    let!(:resource) do
      create(
        :project,
        budget: budget,
        scope: scope1,
        title: Decidim::Faker::Localized.name,
        description: description1
      )
    end

    describe "Indexing of resources" do
      context "when implementing Searchable" do
        context "when on create" do
          it "does indexes a SearchableResource after resource creation" do
            organization.available_locales.each do |locale|
              searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale: locale)
              expect_searchable_resource_to_correspond_to_project(searchable, resource, locale)
            end
          end
        end

        context "when on update" do
          context "when it is updated" do
            before do
              resource.increment(:budget_amount)
            end

            it "updates the associated SearchableResource after update" do
              searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id)
              created_at = searchable.created_at
              updated_title = Decidim::Faker::Localized.name
              expect(resource.update(title: updated_title)).to be_truthy

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale: locale)
                searchable.reload
                expect(searchable.content_a).to eq I18n.transliterate(translated(updated_title, locale: locale))
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
            :project,
            budget: budget,
            scope: scope1,
            title: Decidim::Faker::Localized.name,
            description: Decidim::Faker::Localized.prefixed("Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!", test_locales)
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

    def expect_searchable_resource_to_correspond_to_project(searchable, resource, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(resource.created_at.in_time_zone.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(resource, locale))
    end

    def expected_searchable_resource_attrs(resource, locale)
      {
        "content_a" => I18n.transliterate(translated(resource.title, locale: locale)),
        "content_b" => "",
        "content_c" => "",
        "content_d" => I18n.transliterate(translated(resource.description, locale: locale)),
        "locale" => locale,

        "decidim_organization_id" => resource.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => resource.decidim_scope_id,
        "resource_id" => resource.id,
        "resource_type" => "Decidim::Budgets::Project"
      }
    end
  end
end
