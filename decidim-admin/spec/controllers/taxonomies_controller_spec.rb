# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TaxonomiesController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:taxonomy) { create(:taxonomy, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET index" do
        let!(:taxonomy1) { create(:taxonomy, name: { en: "Category1" }, organization:) }
        let!(:taxonomy2) { create(:taxonomy, name: { en: "Category2" }, organization:) }

        it "assigns @taxonomies" do
          get :index, params: { q: { name_or_children_name_cont: "Category1" } }
          expect(assigns(:taxonomies)).to include(taxonomy1)
          expect(assigns(:taxonomies)).not_to include(taxonomy2)
        end

        it "renders the index template" do
          get :index, params: { q: { name_or_children_name_cont: "Category1" } }
          expect(response).to render_template("index")
        end

        it "breadcrumbs are set" do
          get :index
          expect(controller.helpers.breadcrumb_items).to eq([label: "Taxonomies", url: taxonomies_path])
        end
      end

      describe "GET new" do
        it "assigns a new form instance" do
          get :new
          form = assigns(:form)
          expect(form).to be_a(Decidim::Admin::TaxonomyForm)
          expect(form.id).to be_nil
        end

        it "renders the new template" do
          get :new
          expect(response).to render_template("new")
        end

        it "breadcrumbs are set" do
          get :new
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Taxonomies", url: taxonomies_path },
                                                              { label: "New taxonomy", url: new_taxonomy_path }
                                                            ])
        end
      end

      describe "POST create" do
        let(:valid_params) { { taxonomy: { name: { en: "New Taxonomy" }, weight: 1 } } }
        let(:invalid_params) { { taxonomy: { name: { en: "" }, weight: nil } } }

        it "creates a new taxonomy with valid params" do
          expect do
            post :create, params: valid_params
          end.to change(Decidim::Taxonomy, :count).by(1)
        end

        it "does not create a new taxonomy with invalid params" do
          expect do
            post :create, params: invalid_params
          end.not_to change(Decidim::Taxonomy, :count)
        end
      end

      describe "GET edit" do
        let!(:sub_taxonomy1) { create(:taxonomy, parent: taxonomy, name: { en: "Sub 1" }, organization:) }
        let!(:sub_taxonomy2) { create(:taxonomy, parent: taxonomy, name: { en: "Sub 2" }, organization:) }

        it "assigns the requested taxonomy to @form" do
          get :edit, params: { id: taxonomy.id }
          expect(assigns(:form).attributes).to include("id" => taxonomy.id)
        end

        it "assigns @taxonomies" do
          get :index, params: { id: taxonomy.id, q: { name_or_children_name_cont: "Sub 1" } }
          expect(assigns(:taxonomies)).to include(sub_taxonomy1)
          expect(assigns(:taxonomies)).not_to include(sub_taxonomy2)
        end

        it "renders the edit template" do
          get :edit, params: { id: taxonomy.id }
          expect(response).to render_template("edit")
        end

        context "when editing a non-root taxonomy" do
          let(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }

          it "redirects to the root" do
            get :edit, params: { id: child_taxonomy.id }
            expect(response).to redirect_to(edit_taxonomy_path(taxonomy))
          end
        end

        it "breadcrumbs are set" do
          get :edit, params: { id: taxonomy.id }
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Taxonomies", url: taxonomies_path },
                                                              { label: "Edit taxonomy", url: edit_taxonomy_path(taxonomy) }
                                                            ])
        end
      end

      describe "PATCH update" do
        let(:valid_params) { { id: taxonomy.id, taxonomy: { name: { en: "Updated Taxonomy" }, weight: 1 } } }
        let(:invalid_params) { { id: taxonomy.id, taxonomy: { name: { en: "" }, weight: nil } } }

        it "updates the taxonomy with valid params" do
          patch :update, params: valid_params
          taxonomy.reload

          expect(taxonomy.name["en"]).to eq("Updated Taxonomy")
        end

        it "does not update the taxonomy with invalid params" do
          patch :update, params: invalid_params
          taxonomy.reload

          expect(taxonomy.name["en"]).not_to eq("")
        end
      end

      describe "DELETE destroy" do
        it "deletes the taxonomy" do
          delete :destroy, params: { id: taxonomy.id }
          expect(Decidim::Taxonomy).not_to exist(taxonomy.id)
        end
      end
    end
  end
end
