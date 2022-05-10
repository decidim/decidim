# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    include_context "when a resource is ready for global search"

    let(:current_component) { create :accountability_component, organization: organization }

    let!(:result) do
      create(
        :result,
        component: current_component,
        scope: scope1,
        title: Decidim::Faker::Localized.name,
        description: description1
      )
    end

    # rubocop:disable RSpec/BeforeAfterAll
    # to be removed when results will have a card-m and are declared searchable in its component
    before(:all) do
      manifest = Decidim.find_resource_manifest(Decidim::Accountability::Result)
      manifest.searchable = true
    end

    after(:all) do
      manifest = Decidim.find_resource_manifest(Decidim::Accountability::Result)
      manifest.searchable = false
    end
    # rubocop:enable  RSpec/BeforeAfterAll

    describe "Indexing of results" do
      context "when implementing Searchable" do
        context "when on create" do
          it "does indexes a SearchableResource after Result creation" do
            organization.available_locales.each do |locale|
              searchable = SearchableResource.find_by(resource_type: result.class.name, resource_id: result.id, locale: locale)
              expect_searchable_resource_to_correspond_to_result(searchable, result, locale)
            end
          end
        end

        context "when on update" do
          context "when it is updated" do
            before do
              result.update end_date: Time.zone.today.in(1.year)
            end

            it "updates the associated SearchableResource after update" do
              searchable = SearchableResource.find_by(resource_type: result.class.name, resource_id: result.id)
              created_at = searchable.created_at
              updated_title = Decidim::Faker::Localized.name
              result.update(title: updated_title)

              result.save!
              searchable.reload

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: result.class.name, resource_id: result.id, locale: locale)
                expect(searchable.content_a).to eq I18n.transliterate(translated(updated_title, locale: locale))
                expect(searchable.updated_at).to be > created_at
              end
            end
          end
        end

        context "when on destroy" do
          it "destroys the associated SearchableResource after Result destroy" do
            result.destroy
            searchables = SearchableResource.where(resource_type: result.class.name, resource_id: result.id)
            expect(searchables.any?).to be false
          end
        end
      end
    end

    describe "Search" do
      context "when searching by Result resource_type" do
        let!(:result2) do
          create(
            :result,
            component: current_component,
            scope: scope1,
            title: Decidim::Faker::Localized.name,
            description: Decidim::Faker::Localized.prefixed("Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!", test_locales)
          )
        end

        it "returns Result results" do
          Decidim::Search.call("Ow", organization, resource_type: result.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[result.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [result, result2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("wait", organization, resource_type: result.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[result.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [result2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_result(searchable, result, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(result.start_date.in_time_zone.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(result, locale))
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
        "resource_type" => "Decidim::Accountability::Result"
      }
    end
  end
end
