# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchResourceFieldsMapper do
    subject { resource }

    let(:component) { create(:component, manifest_name: "dummy") }
    let(:scope) { create(:scope, organization: component.organization) }
    let(:resource) do
      dbl = Struct.new(:title, :description, :address, :scope, :component, :datetime).new
      allow(dbl.class).to receive_messages(has_many: 1, after_create: 1, after_update: 1)
      dbl.scope = scope
      dbl.component = component
      dbl.title = "The resource title"
      dbl.description = "The resource description."
      dbl.address = "The resource address."
      dbl.datetime = DateTime.current
      dbl
    end

    describe "#searchable_fields" do
      context "when searchable_fields are correctly setted" do
        context "and resource fields are NOT localized" do
          before do
            subject.class.include Searchable
            subject.class.searchable_fields(
              scope_id: { scope: :id },
              participatory_space: { component: :participatory_space },
              A: [:title],
              D: [:description, :address],
              datetime: :datetime
            )
          end

          it "correctly resolves untranslatable fields into available_locales" do
            mapped_fields = subject.class.search_rsrc_fields_mapper.mapped(subject)

            expected_fields = {
              decidim_scope_id: resource.scope.id,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.datetime,
              i18n: {}
            }
            i18n = expected_fields[:i18n]
            resource.component.organization.available_locales.each do |locale|
              i18n[locale] = { A: resource.title, B: nil, C: nil, D: [resource.description, resource.address].join(" ") }
            end
            expect(mapped_fields).to eq expected_fields
          end
        end

        context "and resource fields ARE localized" do
          before do
            resource.title = { "ca" => "title ca", "en" => "title en", "es" => "title es" }
            subject.class.include Searchable
            subject.class.searchable_fields(
              scope_id: { scope: :id },
              participatory_space: { component: :participatory_space },
              A: [:title],
              D: [:description, :address],
              datetime: :datetime
            )
          end

          it "correctly resolves untranslatable fields into available_locales" do
            mapped_fields = subject.class.search_rsrc_fields_mapper.mapped(subject)
            expected_fields = {
              decidim_scope_id: resource.scope.id,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.datetime,
              i18n: {}
            }
            i18n = expected_fields[:i18n]
            i18n["ca"] = { A: resource.title["ca"], B: nil, C: nil, D: [resource.description, resource.address].join(" ") }
            i18n["en"] = { A: resource.title["en"], B: nil, C: nil, D: [resource.description, resource.address].join(" ") }
            i18n["es"] = { A: resource.title["es"], B: nil, C: nil, D: [resource.description, resource.address].join(" ") }
            expect(mapped_fields).to eq expected_fields
          end
        end
      end
    end
  end
end
