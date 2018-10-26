# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateSerializer do
      subject do
        described_class.new(debate)
      end

      let!(:debate) { create(:debate, :with_author) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { debate.component }

      before do
        debate.update!(category: category)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: debate.id)
        end

        it "serializes the author id" do
          expect(serialized).to include(author_id: debate.author.id)
        end

        context "when there is no author id" do
          it "serializes the author id with nilll" do
            debate.author = nil
            expect(serialized).to include(author_id: nil)
          end
        end

        it "serializes the title" do
          expect(serialized).to include(title: debate.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: debate.description)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: debate.comments.count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(created_at: debate.created_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", debate.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: debate.component.id)
        end
      end
    end
  end
end
