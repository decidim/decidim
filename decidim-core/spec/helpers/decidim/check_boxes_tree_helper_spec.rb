# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CheckBoxesTreeHelper do
    let(:helper) do
      Class.new(ActionView::Base) do
        include CheckBoxesTreeHelper
        include TranslatableAttributes
      end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
    end

    let!(:organization) { create(:organization) }
    let!(:participatory_space) { create(:participatory_process, organization:) }
    let!(:component) { create(:component, participatory_space:) }
    let(:redesign_enabled) { false }

    before do
      allow(helper).to receive(:current_participatory_space).and_return(participatory_space)
      allow(helper).to receive(:current_component).and_return(component)
      allow(helper).to receive(:current_organization).and_return(organization)
      allow(helper).to receive(:redesign_enabled?).and_return(redesign_enabled)
    end

    describe "#filter_scopes_values" do
      let(:root) { helper.filter_scopes_values }
      let(:leaf) { helper.filter_scopes_values.leaf }
      let(:nodes) { helper.filter_scopes_values.node }

      context "when the participatory space does not have a scope" do
        it "returns the global scope" do
          expect(leaf.value).to eq("")
          expect(nodes.count).to eq(1)
          expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreePoint)
          expect(nodes.first.value).to eq("global")
        end
      end

      context "when the participatory space has a scope with subscopes" do
        let(:participatory_space) { create(:participatory_process, :with_scope, organization:) }
        let!(:subscopes) { create_list(:subscope, 5, parent: participatory_space.scope) }

        it "returns all the subscopes" do
          expect(leaf.value).to eq("")
          expect(root).to be_a(Decidim::CheckBoxesTreeHelper::TreeNode)
          expect(root.node.count).to eq(5)
        end
      end

      context "when the component does not have a scope" do
        before do
          component.update!(settings: { scopes_enabled: true, scope_id: nil })
        end

        it "returns the global scope" do
          expect(leaf.value).to eq("")
          expect(nodes.count).to eq(1)
          expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreePoint)
          expect(nodes.first.value).to eq("global")
        end
      end

      context "when the component has a scope with subscopes" do
        let(:participatory_space) { create(:participatory_process, :with_scope, organization:) }
        let!(:subscopes) { create_list(:subscope, 5, parent: participatory_space.scope) }

        before do
          component.update!(settings: { scopes_enabled: true, scope_id: participatory_space.scope.id })
        end

        it "returns all the subscopes" do
          expect(leaf.value).to eq("")
          expect(root).to be_a(Decidim::CheckBoxesTreeHelper::TreeNode)
          expect(root.node.count).to eq(5)
        end
      end
    end

    describe "#filter_global_scopes_values" do
      let(:root) { helper.filter_global_scopes_values }
      let(:leaf) { helper.filter_global_scopes_values.leaf }
      let(:nodes) { helper.filter_global_scopes_values.node }

      it "returns the global scope" do
        expect(leaf.value).to eq("")
        expect(nodes.count).to eq(1)
        expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreePoint)
        expect(nodes.first.value).to eq("global")
      end

      context "when there is a scope with subscopes" do
        let!(:scope) { create(:scope, organization:) }
        let!(:subscopes) { create_list(:subscope, 5, parent: scope) }

        it "returns the global scope, the scope and subscopes" do
          expect(leaf.value).to eq("")
          expect(nodes.count).to eq(2)
          expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreePoint)
          expect(nodes.first.value).to eq("global")
          expect(nodes[1]).to be_a(Decidim::CheckBoxesTreeHelper::TreeNode)
          expect(nodes[1].leaf.value).to eq(scope.id.to_s)
          expect(nodes[1].node.count).to eq(5)
        end
      end
    end
  end
end
