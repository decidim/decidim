# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateSerializer do
      subject do
        described_class.new(debate)
      end

      let!(:debate) { create(:debate) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let!(:scope) { create(:scope, organization: component.participatory_space.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { debate.component }

      before do
        debate.update!(category:)
        debate.update!(scope:)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: debate.id)
        end

        # TODO: add implementatiion
        it "serializes the author" do
          skip
          # expect(serialized).to include(author: debate.title)
        end

        it "serializes the title" do
          expect(serialized).to include(title: debate.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: debate.description)
        end

        it "serializes the start time" do
          expect(serialized).to include(start_time: debate.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include(end_time: debate.end_time)
        end

        it "serializes the information updates" do
          expect(serialized).to include(information_updates: debate.information_updates)
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: debate.component.id)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: debate.reference)
        end

        it "serializes the comments" do
          expect(serialized).to include(comments: debate.comments_count)
        end

        it "serializes the followers" do
          expect(serialized).to include(followers: debate.follows.size)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", debate.id.to_s)
        end

        it "serializes the conclusions" do
          expect(serialized).to include(conclusions: debate.conclusions)
        end

        it "serializes the closed at" do
          expect(serialized).to include(closed_at: debate.closed_at)
        end

        it "serializes the last comment at" do
          expect(serialized).to include(last_comment_at: debate.last_comment_at)
        end

        it "serializes the comments enabled" do
          expect(serialized).to include(comments_enabled: debate.comments_enabled)
        end
      end
    end
  end
end
