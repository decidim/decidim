# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentSerializer do
      let(:comment) { create(:comment) }

      subject { described_class.new(comment) }

      describe "#serialize" do
        it "includes the id" do
          expect(subject.serialize).to include(id: comment.id)
        end

        it "includes the creation date" do
          expect(subject.serialize).to include(created_at: comment.created_at)
        end

        it "includes the body" do
          expect(subject.serialize).to include(body: comment.body.values.first)
        end

        it "includes the body locale" do
          expect(subject.serialize).to include(locale: comment.body.keys.first)
        end

        it "includes the author" do
          expect(subject.serialize[:author]).to(
            include(id: comment.author.id, name: comment.author.name)
          )
        end

        it "includes the alignment" do
          expect(subject.serialize).to include(alignment: comment.alignment)
        end

        it "includes the depth" do
          expect(subject.serialize).to include(alignment: comment.depth)
        end

        it "includes the root commentable's url" do
          expect(subject.serialize[:root_commentable_url]).to match(/http/)
        end

        context "when the author has been deleted" do
          let(:commentable) { create(:dummy_resource, :published) }
          let(:comment) do
            user = create(:user, :confirmed, organization: commentable.organization)
            c = create(:comment, commentable:, root_commentable: commentable, author: user)
            Decidim::User.where(id: user.id).delete_all
            c.reload
          end

          it "serializes without error" do
            expect { subject.serialize }.not_to raise_error
          end

          it "returns nil for author fields" do
            serialized = subject.serialize
            expect(serialized[:author][:id]).to be_nil
            expect(serialized[:author][:name]).to be_nil
          end
        end
      end
    end
  end
end
