# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::ContentBlocks
  describe ReorderContentBlocks do
    subject { described_class.new(*args) }

    let(:args) { [organization, scope, order] }
    let(:organization) { create(:organization) }
    let(:scope) { :homepage }
    let(:resource1) do
      create(:newsletter, organization:)
    end
    let(:resource2) do
      create(:newsletter, organization:)
    end
    let(:scoped_resource_id) { resource1.id }
    let!(:resource1_published_block) do
      create(
        :content_block,
        organization:,
        scope_name: scope,
        manifest_name: :hero,
        weight: 1,
        scoped_resource_id: resource1.id
      )
    end
    let!(:resource2_unpublished_block) do
      create(
        :content_block,
        organization:,
        scope_name: scope,
        published_at: nil,
        manifest_name: :sub_hero,
        weight: 2,
        scoped_resource_id: resource2.id
      )
    end
    let!(:published_block1) do
      create(
        :content_block,
        scope_name: scope,
        manifest_name: :hero,
        organization:,
        weight: 1
      )
    end
    let!(:published_block2) do
      create(
        :content_block,
        scope_name: scope,
        manifest_name: :sub_hero,
        organization:,
        weight: 2
      )
    end
    let!(:unpublished_block) do
      create(
        :content_block,
        scope_name: scope,
        published_at: nil,
        manifest_name: :footer_sub_hero,
        organization:
      )
    end
    let(:order) { [published_block2.id, unpublished_block.id] }

    context "when the order is nil" do
      let(:order) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is empty" do
      let(:order) { [] }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is valid" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "reorders the blocks" do
        subject.call
        published_block1.reload
        published_block2.reload
        unpublished_block.reload

        expect(published_block2.weight).to eq 1
        expect(unpublished_block.weight).to eq 2
        expect(published_block1.weight).to be_nil
      end

      it "unpublishes a published block that disappears from the order" do
        subject.call
        published_block1.reload

        expect(published_block1).not_to be_published
      end

      it "publishes an unpublished block that appears in the order" do
        subject.call
        unpublished_block.reload

        expect(unpublished_block).to be_published
      end
    end

    context "when scoped resource is present and order is valid" do
      let(:order) { [resource2_unpublished_block.id, resource1_published_block.id, unpublished_block.id] }
      let(:args) { [organization, scope, order, scoped_resource_id] }

      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "only affects to content blocks associated with the resource" do
        expect { subject.call }.not_to change(Decidim::ContentBlock, :count)

        published_block1.reload
        published_block2.reload
        unpublished_block.reload
        resource1_published_block.reload
        resource2_unpublished_block.reload

        expect(published_block1.weight).to eq 1
        expect(published_block2.weight).to eq 2
        expect(unpublished_block.published_at).to be_nil
        expect(resource1_published_block.weight).to eq 2
        expect(resource2_unpublished_block.weight).to eq 2
        expect(resource2_unpublished_block.published_at).to be_nil

        order.each_with_index do |id, index|
          next unless id == resource1_published_block.id

          expect(Decidim::ContentBlock.for_scope(scope, organization:).where(scoped_resource_id:, id:)).to exist
          expect(Decidim::ContentBlock.for_scope(scope, organization:).find_by(scoped_resource_id:, id:).weight).to eq index + 1
        end
      end
    end
  end
end
