# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe DeleteResultType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { ResultMutationType }
    let!(:model) { create(:result, component: current_component) }
    let(:current_component) { create(:accountability_component) }
    let(:current_organization) { current_component.organization }

    let(:query) do
      %( mutation { deleteResult(id: #{model.id}) { id } })
    end

    shared_examples "API deletable result" do
      it "deletes the budget" do
        expect(model.deleted_at).to be_nil
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Accountability::Result, :count).by(-1)
        expect(model.reload.deleted_at).to be_present
      end

      context "when missing result" do
        context "when budget is missing" do
          let(:query) { %( mutation { deleteResult(id: 9999999) { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /not found/)
          end
        end

        context "when budget id is not integer" do
          let(:query) { %( mutation { deleteResult(id: "aaaa") { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /not found/)
          end
        end

        context "when budget is already deleted" do
          let!(:model) { create(:result, component: current_component) }

          before { model.delete }

          it "returns an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /not found/)
          end
        end

        context "when budget belongs to another component" do
          let!(:model2) { create(:result, component: current_component2) }
          let(:current_component2) { create(:accountability_component) }
          let(:query) { %( mutation { deleteResult(id: #{model2.id}) { id } } ) }

          it "returns an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /not found/)
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API deletable result"
  end
end
