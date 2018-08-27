# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ReorderContentBlocks do
    subject { described_class.new(organization, scope, order) }

    let(:organization) { create :organization }
    let(:scope) { :my_scope }
    let!(:published_block1) do
      create(
        :content_block,
        scope: scope,
        manifest_name: :manifest1,
        organization: organization,
        weight: 1
      )
    end
    let!(:published_block2) do
      create(
        :content_block,
        scope: scope,
        manifest_name: :manifest2,
        organization: organization,
        weight: 2
      )
    end
    let!(:unpublished_block) do
      create(
        :content_block,
        scope: scope,
        published_at: nil,
        manifest_name: :manifest3,
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
        expect(published_block1.weight).to eq nil
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
        let(:order) { [:my_new_manifest] }

        it "is valid" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates the new content block" do
          expect { subject.call }.to change(Decidim::ContentBlock, :count).by(1)
          content_block = Decidim::ContentBlock.last

          expect(content_block.organization).to eq organization
          expect(content_block.weight).to eq 1
          expect(content_block.scope).to eq scope.to_s
          expect(content_block).to be_published
        end
      end
    end
  end
end
