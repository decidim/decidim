# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TaxonomyFiltersController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:root_taxonomy) { taxonomy.parent }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET index" do
        it "renders the index template" do
          get :index, params: { taxonomy_id: root_taxonomy.id }
          expect(response).to render_template("index")
        end

        it "breadcrumbs are set" do
          get :index, params: { taxonomy_id: root_taxonomy.id }
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Taxonomies", url: taxonomies_path },
                                                              { label: root_taxonomy.name, url: taxonomy_filters_path },
                                                              { label: "Filters", url: taxonomy_filters_path }
                                                            ])
        end
      end

      describe "GET new" do
        it "assigns a new form instance" do
          get :new, params: { taxonomy_id: root_taxonomy.id }
          form = assigns(:form)
          expect(form).to be_a(Decidim::Admin::TaxonomyFilterForm)
          expect(form.id).to be_nil
        end

        it "renders the new template" do
          get :new, params: { taxonomy_id: root_taxonomy.id }
          expect(response).to render_template("new")
        end

        it "breadcrumbs are set" do
          get :new, params: { taxonomy_id: root_taxonomy.id }
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Taxonomies", url: taxonomies_path },
                                                              { label: root_taxonomy.name, url: taxonomy_filters_path },
                                                              { label: "Filters", url: taxonomy_filters_path },
                                                              { label: "New filter", url: new_taxonomy_filter_path }
                                                            ])
        end
      end

      describe "POST create" do
        let(:valid_params) { { taxonomy_id: root_taxonomy.id, root_taxonomy_id: root_taxonomy.id, taxonomy_items: [taxonomy.id] } }
        let(:invalid_params) { { taxonomy_id: root_taxonomy.id, root_taxonomy_id: root_taxonomy.id } }

        it "creates a new taxonomy filter with valid params" do
          expect do
            post :create, params: valid_params
          end.to change(Decidim::TaxonomyFilter, :count).by(1)
        end

        it "does not create a new taxonomy filter with invalid params" do
          expect do
            post :create, params: invalid_params
          end.not_to change(Decidim::TaxonomyFilter, :count)
        end
      end

      describe "GET edit" do
        it "assigns the requested taxonomy filter to @form" do
          get :edit, params: { taxonomy_id: root_taxonomy.id, id: taxonomy_filter.id }
          expect(assigns(:form).attributes).to include("id" => taxonomy_filter.id)
        end

        it "renders the edit template" do
          get :edit, params: { taxonomy_id: root_taxonomy.id, id: taxonomy_filter.id }
          expect(response).to render_template("edit")
        end

        context "when editing a filter with a different root taxonomy" do
          let(:another_root_taxonomy) { create(:taxonomy, organization:) }

          it "redirects to the root" do
            get :edit, params: { taxonomy_id: another_root_taxonomy.id, id: taxonomy_filter.id }
            expect(response).to redirect_to(taxonomy_filters_path(another_root_taxonomy))
          end
        end

        it "breadcrumbs are set" do
          get :edit, params: { taxonomy_id: root_taxonomy.id, id: taxonomy_filter.id }
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Taxonomies", url: taxonomies_path },
                                                              { label: root_taxonomy.name, url: taxonomy_filters_path },
                                                              { label: "Filters", url: taxonomy_filters_path },
                                                              { label: "Edit filter", url: edit_taxonomy_filter_path }
                                                            ])
        end
      end

      describe "PATCH update" do
        let(:valid_params) do
          {
            taxonomy_id: root_taxonomy.id,
            root_taxonomy_id: root_taxonomy.id,
            id: taxonomy_filter.id,
            taxonomy_filter: {
              taxonomy_items: [taxonomy.id],
              name: { en: "Updated taxonomy filter" }
            }
          }
        end
        let(:invalid_params) do
          {
            taxonomy_id: root_taxonomy.id,
            root_taxonomy_id: root_taxonomy.id,
            id: taxonomy_filter.id,
            taxonomy_filter: {
              taxonomy_items: [],
              name: { en: "" }
            }
          }
        end

        it "updates the taxonomy with valid params" do
          patch :update, params: valid_params
          taxonomy_filter.reload

          expect(taxonomy_filter.name["en"]).to eq("Updated taxonomy filter")
        end

        it "does not update the taxonomy with invalid params" do
          patch :update, params: invalid_params
          taxonomy_filter.reload

          expect(taxonomy_filter.name["en"]).not_to eq("")
        end
      end

      describe "DELETE destroy" do
        it "deletes the taxonomy" do
          delete :destroy, params: { taxonomy_id: root_taxonomy.id, id: taxonomy_filter.id }
          expect(Decidim::TaxonomyFilter).not_to exist(taxonomy.id)
        end
      end
    end
  end
end
