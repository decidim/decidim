# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchResourceFieldsMapper do
    describe "with searchable_fields" do
      subject { resource }

      before do
        resource.organization.available_locales = %w(en ca es)
      end

      context "when resource is inside a participatory space" do
        let!(:resource) do
          Decidim::DummyResources::DummyResource.new(
            scope:,
            component:,
            title: { en: "The resource title" },
            address: "The resource address.",
            published_at: Time.current
          )
        end
        let(:component) { create(:component, manifest_name: "dummy") }
        let(:scope) { create(:scope, organization: component.organization) }

        context "when searchable_fields are correctly setted" do
          it "maps default fields" do
            mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)

            expected_fields = {
              decidim_scope_id: resource.scope.id,
              decidim_participatory_space_id: resource.component.participatory_space_id,
              decidim_participatory_space_type: resource.component.participatory_space_type,
              decidim_organization_id: resource.component.organization.id,
              datetime: resource.published_at
            }

            expect(mapped_fields).to include(expected_fields)
          end

          context "and resource fields are NOT localized" do
            it "correctly resolves untranslatable fields into available_locales" do
              mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)

              expected_fields = {
                i18n: {
                  "ca" => { A: kind_of(String), B: nil, C: nil, D: resource.address },
                  "en" => { A: kind_of(String), B: nil, C: nil, D: resource.address },
                  "es" => { A: kind_of(String), B: nil, C: nil, D: resource.address }
                }
              }

              expect(mapped_fields).to include(expected_fields)
            end
          end

          context "and resource fields ARE localized" do
            before do
              resource.title = { "ca" => "title ca", "en" => "title en", "es" => "title es" }
            end

            it "correctly resolves the fields into available_locales" do
              mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
              expected_fields = {
                i18n: {
                  "ca" => { A: "title ca", B: nil, C: nil, D: kind_of(String) },
                  "en" => { A: "title en", B: nil, C: nil, D: kind_of(String) },
                  "es" => { A: "title es", B: nil, C: nil, D: kind_of(String) }
                }
              }

              expect(mapped_fields).to include(expected_fields)
            end
          end

          context "and resource fields have machine translations" do
            before do
              resource.title = { "en" => "title en", "machine_translations" => { "es" => "title es" } }
            end

            it "correctly resolves machine_translations into available_locales" do
              mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)

              expected_fields = {
                i18n: {
                  "ca" => { A: "", B: nil, C: nil, D: resource.address },
                  "en" => { A: "title en", B: nil, C: nil, D: resource.address },
                  "es" => { A: "title es", B: nil, C: nil, D: resource.address }
                }
              }

              expect(mapped_fields).to include(expected_fields)
            end
          end

          context "and resource fields have content that has been processed" do
            before do
              allow(Decidim).to receive(:content_processors).and_return([:dummy_foo, :dummy_bar])
              resource.title = { "en" => "title %lorem%", "machine_translations" => { "es" => "title *ipsum*" } }
            end

            it "gets the rendered value" do
              mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)

              expected_fields = {
                i18n: {
                  "ca" => { A: "", B: nil, C: nil, D: resource.address },
                  "en" => { A: "title neque dicta enim quasi", B: nil, C: nil, D: resource.address },
                  "es" => { A: "title illo qui voluptas", B: nil, C: nil, D: resource.address }
                }
              }

              expect(mapped_fields).to include(expected_fields)
            end
          end

          context "and scope is not setted" do
            it "correctly resolves fields" do
              resource.scope = nil
              expected_fields = { decidim_scope_id: nil }

              mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
              expect(mapped_fields).to include(expected_fields)
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
            organization:
          )
        end

        it "correctly resolves organization_id" do
          expected_fields = {
            decidim_scope_id: nil,
            decidim_participatory_space_id: nil,
            decidim_participatory_space_type: nil,
            decidim_organization_id: organization.id
          }

          mapped_fields = subject.class.search_resource_fields_mapper.mapped(subject)
          expect(mapped_fields).to include(expected_fields)
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
