# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:organization) { create(:organization) }
    let(:scope1) { create :scope, organization: organization }
    let!(:user) { create(:user, name: "Neil Diamond", organization: organization) }

    describe "Indexing of users" do
      context "when implementing Searchable" do
        it "inserts a SearchableResource after User creation" do
          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: user.class.name, resource_id: user.id, locale: locale)
            expect_searchable_resource_to_correspond_to_user(searchable, user, locale)
          end
        end

        it "updates the associated SearchableResource after User update" do
          searchable = SearchableResource.find_by(resource_type: user.class.name, resource_id: user.id)
          created_at = searchable.created_at
          user.save!

          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: user.class.name, resource_id: user.id, locale: locale)
            expect(searchable.content_a).to eq user.name
            expect(searchable.updated_at).to be > created_at
          end
        end

        it "destroys the associated SearchableResource after User destroy" do
          user.destroy

          searchables = SearchableResource.where(resource_type: user.class.name, resource_id: user.id)

          expect(searchables.any?).to be false
        end
      end
    end

    describe "Search" do
      context "when searching by User resource_type" do
        let!(:user2) { create(:user, name: "Neil Young", organization: organization) }

        it "returns User results" do
          Decidim::Search.call("Neil", organization, resource_type: user.class.name) do
            on(:ok) do |results|
              expect(results.count).to eq 2
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_user(searchable, user, locale)
      attrs = searchable.attributes
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs["datetime"].to_s).to eq(user.created_at.to_s)
      attrs.delete("datetime")
      expect(attrs).to eq(expected_searchable_resource_attrs(user, locale))
    end

    def expected_searchable_resource_attrs(resource, locale)
      {
        "content_a" => resource.name,
        "content_b" => "",
        "content_c" => "",
        "content_d" => "",
        "locale" => locale,

        "decidim_organization_id" => resource.organization.id,
        "decidim_participatory_space_id" => nil,
        "decidim_participatory_space_type" => nil,
        "decidim_scope_id" => nil,
        "resource_id" => resource.id,
        "resource_type" => "Decidim::User"
      }
    end
  end
end
