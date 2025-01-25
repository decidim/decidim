# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TaxonomyFiltersSelectorController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:root_taxonomy) { taxonomy.parent }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let(:component) { create(:dummy_component, organization:) }
      let(:params) do
        {
          component_id:,
          taxonomy_id:,
          taxonomy_filter_id:
        }
      end
      let(:component_id) { component.id }
      let(:taxonomy_id) { nil }
      let(:taxonomy_filter_id) { nil }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      shared_examples "a forbidden action" do |action|
        it "raises Decidim::ActionForbidden" do
          get(action, params:)

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to("/admin/")
        end
      end

      shared_examples "redirects to index" do |action|
        it "redirects to index" do
          get(action, params:)

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to("/admin/taxonomy_filters_selector?component_id=#{component_id}")
        end
      end

      shared_examples "redirects to new" do |action|
        it "redirects to new" do
          get(action, params:)

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to("/admin/taxonomy_filters_selector/new?component_id=#{component_id}&taxonomy_id=#{taxonomy_id}")
        end
      end

      shared_examples "ignores the taxonomy" do |action|
        it "ignores the taxonomy" do
          get(action, params:)

          expect(controller.helpers.root_taxonomy).to be_nil
          expect(response).to render_template("index")
        end
      end

      describe "GET index" do
        it "renders the index template" do
          get(:index, params:)

          expect(controller.helpers.component).to eq(component)
          expect(response).to render_template("index")
        end

        context "when taxonomy id is defined" do
          let(:taxonomy_id) { root_taxonomy.id }

          it "root_taxonomy is a helper" do
            get(:index, params:)

            expect(controller.helpers.root_taxonomy).to eq(root_taxonomy)
          end

          context "and is not a root taxonomy" do
            let(:taxonomy_id) { taxonomy.id }

            it_behaves_like "ignores the taxonomy", :index
          end

          context "and belongs to another organization" do
            let(:taxonomy) { create(:taxonomy, :with_parent) }

            it_behaves_like "ignores the taxonomy", :index
          end
        end

        context "when component id is not present" do
          let(:component_id) { nil }

          it_behaves_like "a forbidden action", :index
        end
      end

      describe "GET new" do
        let(:taxonomy_id) { root_taxonomy.id }

        it "renders the new template" do
          get(:new, params:)

          expect(controller.helpers.component).to eq(component)
          expect(controller.helpers.root_taxonomy).to eq(root_taxonomy)
          expect(controller.helpers.taxonomy_filter).to be_nil
          expect(response).to render_template("new")
        end

        context "when taxonomy filter id is defined" do
          let(:taxonomy_filter_id) { taxonomy_filter.id }

          it "taxonomy_filter is a helper" do
            get(:new, params:)

            expect(controller.helpers.taxonomy_filter).to eq(taxonomy_filter)
          end

          context "and belongs to another taxonomy" do
            let(:another_taxonomy_filter) { create(:taxonomy_filter) }
            let(:taxonomy_filter_id) { another_taxonomy_filter.id }

            it "ignores the taxonomy filter" do
              get(:new, params:)

              expect(controller.helpers.taxonomy_filter).to be_nil
              expect(response).to render_template("new")
            end
          end
        end

        context "and taxonomy id is not present" do
          let(:taxonomy_id) { nil }

          it_behaves_like "redirects to index", :new
        end
      end

      describe "POST create" do
        let(:taxonomy_id) { root_taxonomy.id }
        let(:taxonomy_filter_id) { taxonomy_filter.id }

        it "adds the taxonomy filter to the component" do
          post(:create, params:)

          expect(component.reload.settings.taxonomy_filters).to include(taxonomy_filter.id.to_s)
          expect(response).to render_template("_component_table")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("update_filters", component, current_user)
            .and_call_original

          expect { post(:create, params:) }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("update_filters")
          expect(action_log.version).to be_present
        end

        it "increments the components_count" do
          expect(taxonomy_filter.components_count).to eq(0)
          post(:create, params:)
          expect(taxonomy_filter.reload.components_count).to eq(1)
        end

        context "when taxonomy filter id is not present" do
          let(:taxonomy_filter_id) { nil }

          it_behaves_like "redirects to new", :create
        end
      end

      describe "GET show" do
        let(:taxonomy_id) { root_taxonomy.id }
        let(:taxonomy_filter_id) { taxonomy_filter.id }

        it "renders the show template" do
          get(:show, params:)

          expect(controller.helpers.component).to eq(component)
          expect(controller.helpers.root_taxonomy).to eq(root_taxonomy)
          expect(controller.helpers.taxonomy_filter).to eq(taxonomy_filter)
          expect(response).to render_template("show")
        end

        context "when taxonomy filter id is invalid" do
          let(:taxonomy_filter_id) { 0 }

          it_behaves_like "redirects to new", :show
        end
      end

      describe "DELETE destroy" do
        let(:taxonomy_id) { root_taxonomy.id }
        let(:taxonomy_filter_id) { taxonomy_filter.id }

        before do
          component.update!(settings: { taxonomy_filters: [taxonomy_filter.id.to_s] })
          taxonomy_filter.reload
        end

        it "removes the taxonomy filter from the component" do
          expect(component.reload.settings.taxonomy_filters).to include(taxonomy_filter.id.to_s)
          delete(:destroy, params:)

          expect(component.reload.settings.taxonomy_filters).not_to include(taxonomy_filter.id.to_s)
          expect(response).to render_template("_component_table")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("update_filters", component, current_user)
            .and_call_original

          expect { delete(:destroy, params:) }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("update_filters")
          expect(action_log.version).to be_present
        end

        it "decrements the components_count" do
          expect(taxonomy_filter.components_count).to eq(1)
          delete(:destroy, params:)
          expect(taxonomy_filter.reload.components_count).to eq(0)
        end

        context "when taxonomy filter id is invalid" do
          let(:taxonomy_filter_id) { 0 }

          it "ignores the taxonomy filter" do
            delete(:destroy, params:)

            expect(component.reload.settings.taxonomy_filters).to include(taxonomy_filter.id.to_s)
            expect(response).to render_template("_component_table")
          end
        end
      end
    end
  end
end
