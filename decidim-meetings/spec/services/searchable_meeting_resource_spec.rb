# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:current_component) { create :component, manifest_name: "meetings" }
    let(:organization) { current_component.organization }
    let(:scope1) { create :scope, organization: }
    let!(:meeting) do
      create(
        :meeting,
        :published,
        component: current_component,
        scope: scope1,
        title: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt."),
        description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt description."),
        address: "Some very centric address"
      )
    end

    describe "Indexing of meetings" do
      context "when implementing Searchable" do
        it "inserts a SearchableResource after Meeting creation" do
          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: meeting.class.name, resource_id: meeting.id, locale:)
            expect_searchable_resource_to_correspond_to_meeting(searchable, meeting, locale)
          end
        end

        it "updates the associated SearchableResource after Meeting update" do
          searchable = SearchableResource.find_by(resource_type: meeting.class.name, resource_id: meeting.id)
          created_at = searchable.created_at
          updated_title = organization.available_locales.inject({}) do |modifs, locale|
            meeting.title[locale] += locale.upcase
            modifs.update(locale => meeting.title[locale])
          end

          meeting.save!

          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: meeting.class.name, resource_id: meeting.id, locale:)
            expect(searchable.content_a).to eq updated_title[locale]
            expect(searchable.updated_at).to be > created_at
          end
        end

        it "destroys the associated SearchableResource after Meeting destroy" do
          meeting.destroy

          searchables = SearchableResource.where(resource_type: meeting.class.name, resource_id: meeting.id)

          expect(searchables.any?).to be false
        end
      end
    end

    describe "Search" do
      context "when searching by Meeting resource_type" do
        let!(:meeting2) do
          create(
            :meeting,
            :published,
            component: current_component,
            scope: scope1,
            title: Decidim::Faker::Localized.name,
            description: Decidim::Faker::Localized.paragraph,
            address: "Some address in the suburbs containing Nulla"
          )
        end

        it "returns Meeting results" do
          Decidim::Search.call("Nulla", organization, resource_type: meeting.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[meeting.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [meeting, meeting2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("subu", organization, resource_type: meeting.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[meeting.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [meeting2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_meeting(searchable, meeting, locale)
      attrs = searchable.attributes
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs["datetime"].to_s).to eq(meeting.start_time.to_s)
      attrs.delete("datetime")
      expect(attrs).to eq(expected_searchable_resource_attrs(meeting, locale))
    end

    def expected_searchable_resource_attrs(meeting, locale)
      {
        "content_a" => meeting.title[locale],
        "content_b" => "",
        "content_c" => "",
        "content_d" => [meeting.description[locale], meeting.address].join(" "),
        "locale" => locale,

        "decidim_organization_id" => meeting.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => meeting.decidim_scope_id,
        "resource_id" => meeting.id,
        "resource_type" => "Decidim::Meetings::Meeting"
      }
    end
  end
end
