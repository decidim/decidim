# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TaxonomyItemsController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:taxonomy) { create(:taxonomy, organization:) }
      let!(:taxonomy_item) { create(:taxonomy, parent: taxonomy, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "taxonomy lookup" do
        it "finds a taxonomy belonging to the current organization" do
          get :new, params: { taxonomy_id: taxonomy.id }

          expect(response).to render_template("new")
          expect(assigns(:taxonomy)).to eq(taxonomy)
        end

        context "when the taxonomy belongs to another organization" do
          let(:other_organization) { create(:organization) }
          let(:other_taxonomy) { create(:taxonomy, organization: other_organization) }

          it "returns a not-found response" do
            expect do
              get :new, params: { taxonomy_id: other_taxonomy.id }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe "taxonomy_item lookup" do
        it "finds a taxonomy item belonging to the current organization" do
          get :edit, params: { taxonomy_id: taxonomy.id, id: taxonomy_item.id }

          expect(response).to render_template("edit")
          expect(assigns(:taxonomy_item)).to eq(taxonomy_item)
        end

        context "when the taxonomy item belongs to another organization" do
          let(:other_organization) { create(:organization) }
          let(:other_taxonomy) { create(:taxonomy, organization: other_organization) }
          let!(:other_taxonomy_item) { create(:taxonomy, parent: other_taxonomy, organization: other_organization) }

          it "returns a not-found response" do
            expect do
              get :edit, params: { taxonomy_id: taxonomy.id, id: other_taxonomy_item.id }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
