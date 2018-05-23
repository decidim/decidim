# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchResourceFieldsMapper do
    subject { resource }

    let(:component) { create(:component, manifest_name: "dummy") }
    let(:scope) { create(:scope, organization: component.organization) }
    let!(:resource) do
      Decidim::DummyResources::DummyResource.new(
        scope: scope,
        component: component,
        title: "The resource title",
        address: "The resource address.",
        published_at: DateTime.current
      )
    end

    describe "#searchable_fields" do
      context "when searchable_fields are correctly setted" do
        context "and resource fields are NOT localized" do
          it "correctly resolves untranslatable fields into available_locales" do
            mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)

            expected_fields = {
              decidim_scope_id: resource.scope.id,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.published_at,
              i18n: {}
            }
            i18n = expected_fields[:i18n]
            resource.component.organization.available_locales.each do |locale|
              i18n[locale] = { A: resource.title, B: nil, C: nil, D: [resource.address].join(" ") }
            end
            expect(mapped_fields).to eq expected_fields
          end
        end

        context "and resource fields ARE localized" do
          before do
            resource.title = { "ca" => "title ca", "en" => "title en", "es" => "title es" }
          end

          it "correctly resolves untranslatable fields into available_locales" do
            mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
            expected_fields = {
              decidim_scope_id: resource.scope.id,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.published_at,
              i18n: {}
            }
            i18n = expected_fields[:i18n]
            i18n["ca"] = { A: resource.title, B: nil, C: nil, D: resource.address }
            i18n["en"] = { A: resource.title, B: nil, C: nil, D: resource.address }
            i18n["es"] = { A: resource.title, B: nil, C: nil, D: resource.address }
            expect(mapped_fields).to eq expected_fields
          end
        end

        context "and scope is not setted" do
          it "correctly resolves fields" do
            resource.scope = nil
            expected_fields = {
              decidim_scope_id: nil,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.published_at,
              i18n: {}
            }
            i18n = expected_fields[:i18n]
            resource.component.organization.available_locales.each do |locale|
              i18n[locale] = { A: resource.title, B: nil, C: nil, D: [resource.address].join(" ") }
            end

            mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
            expect(mapped_fields).to eq expected_fields
          end
        end
      end
    end
  end
end
