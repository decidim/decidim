# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ReorderContentBlocks do
    subject { described_class.new(*args) }

    let(:args) { [organization, scope, order] }
    let(:organization) { create :organization }
    let(:scope) { :homepage }
    let(:resource1) do
      create(:newsletter, organization: organization)
    end
    let(:resource2) do
      create(:newsletter, organization: organization)
    end
    let(:scoped_resource_id) { resource1.id }
    let!(:resource1_published_block) do
      create(
        :content_block,
        organization: organization,
        scope_name: scope,
        manifest_name: :hero,
        weight: 1,
        scoped_resource_id: resource1.id
      )
    end
    let!(:resource2_unpublished_block) do
      create(
        :content_block,
        organization: organization,
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
        organization: organization,
        weight: 1
      )
    end
    let!(:published_block2) do
      create(
        :content_block,
        scope_name: scope,
        manifest_name: :sub_hero,
        organization: organization,
        weight: 2
      )
    end
    let!(:unpublished_block) do
      create(
        :content_block,
        scope_name: scope,
        published_at: nil,
        manifest_name: :footer_sub_hero,
        organization: organization
      )
    end
    let(:order) { [published_block2.manifest_name, unpublished_block.manifest_name] }

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

      context "when it adds a new content block" do
        let(:order) { [:highlighted_content_banner] }

        it "is valid" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates the new content block" do
          expect { subject.call }.to change(Decidim::ContentBlock, :count).by(1)
          content_block = Decidim::ContentBlock.last

          expect(content_block.organization).to eq organization
          expect(content_block.weight).to eq 1
          expect(content_block.scope_name).to eq scope.to_s
          expect(content_block).to be_published
        end
      end
    end

    context "when scoped resource is present and order is valid" do
      let(:order) { [resource2_unpublished_block.manifest_name, resource1_published_block.manifest_name, unpublished_block.manifest_name] }
      let(:args) { [organization, scope, order, scoped_resource_id] }

      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "only affects to content blocks associated with the resource" do
        expect { subject.call }.to change(Decidim::ContentBlock, :count).by(2)

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

        order.each_with_index do |manifest_name, index|
          expect(Decidim::ContentBlock.for_scope(scope, organization: organization).where(scoped_resource_id: scoped_resource_id, manifest_name: manifest_name)).to exist
          expect(Decidim::ContentBlock.for_scope(scope, organization: organization).find_by(scoped_resource_id: scoped_resource_id, manifest_name: manifest_name).weight).to eq index + 1
        end
      end
    end
  end
end
