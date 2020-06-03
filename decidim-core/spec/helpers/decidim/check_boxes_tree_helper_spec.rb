# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CheckBoxesTreeHelper do
    let(:helper) do
      Class.new(ActionView::Base) do
        include CheckBoxesTreeHelper
        include TranslatableAttributes
      end.new
    end

    let!(:organization) { create(:organization) }
    let!(:participatory_space) { create(:participatory_process, organization: organization) }

    before do
      allow(helper).to receive(:current_participatory_space).and_return(participatory_space)
    end

    describe "#filter_scopes_values" do
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

      context "when the participatory space has a scope" do
        let!(:participatory_space) { create(:participatory_process, :with_scope, organization: organization) }

        it "returns the participatory space's scope" do
          expect(leaf.value).to eq("")
          expect(nodes.count).to eq(1)
          expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreeNode)
          expect(nodes.first.leaf).to be_a(Decidim::CheckBoxesTreeHelper::TreePoint)
          expect(nodes.first.leaf.value).to eq(participatory_space.scope.id.to_s)
          expect(nodes.first.leaf.label).to eq(participatory_space.scope.name["en"])
        end

        context "with subscopes" do
          let!(:subscopes) { create_list :subscope, 5, parent: participatory_space.scope }

          it "returns all the subscopes" do
            expect(leaf.value).to eq("")
            expect(nodes.first).to be_a(Decidim::CheckBoxesTreeHelper::TreeNode)
            expect(nodes.first.node.count).to eq(5)
          end
        end
      end
    end
  end
end
