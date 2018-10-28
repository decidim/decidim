# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchResourceFieldsMapper do
    describe "with searchable_fields" do
      subject { resource }

      context "when resource is inside a participatory space" do
        let!(:resource) do
          Decidim::DummyResources::DummyResource.new(
            scope: scope,
            component: component,
            title: "The resource title",
            address: "The resource address.",
            published_at: Time.current
          )
        end
        let(:component) { create(:component, manifest_name: "dummy") }
        let(:scope) { create(:scope, organization: component.organization) }

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

      context "when resource is outside a participatory space" do
        let(:organization) { create(:organization) }
        let(:user_name) { Faker.name }
        let!(:resource) do
          Decidim::User.new(
            name: user_name,
            organization: organization
          )
        end

        it "correctly resolves organization_id" do
          expected_fields = {
            decidim_scope_id: nil,
            decidim_participatory_space_id: nil,
            decidim_participatory_space_type: nil,
            decidim_organization_id: organization.id,
            datetime: resource.created_at,
            i18n: {}
          }
          i18n = expected_fields[:i18n]
          resource.organization.available_locales.each do |locale|
            i18n[locale] = { A: resource.name, B: nil, C: nil, D: nil }
          end

          mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
          expect(mapped_fields).to eq expected_fields
        end
      end
    end

    describe "with index_on_create" do
      subject { SearchResourceFieldsMapper.new({}) }

      context "with defaults" do
        it "does index the resource" do
          expect(subject).to be_index_on_create(nil)
        end
      end

      context "when setting a boolean" do
        it "DOES index the resource if true is setted" do
          subject.set_index_condition(:create, true)
          expect(subject).to be_index_on_create(nil)
        end
        it "does NOT index the resource if false is setted" do
          subject.set_index_condition(:create, false)
          expect(subject).not_to be_index_on_create(nil)
        end
      end
    end

    describe "with index_on_update" do
      subject { SearchResourceFieldsMapper.new({}) }

      context "with defaults" do
        it "does index the resource" do
          expect(subject).to be_index_on_update(nil)
        end
      end

      context "when setting a boolean" do
        it "DOES index the resource if true is setted" do
          subject.set_index_condition(:update, true)
          expect(subject).to be_index_on_update(nil)
        end
        it "does NOT index the resource if false is setted" do
          subject.set_index_condition(:update, false)
          expect(subject).not_to be_index_on_update(nil)
        end
      end
    end
  end
end
