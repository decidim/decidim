# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnlikeResource do
    describe "user unlike resource" do
      let(:like) { create(:like) }
      let(:command) { described_class.new(like.resource, like.author) }

      it "broadcasts ok" do
        expect(like).to be_valid
        expect { command.call }.to broadcast :ok
      end

      it "removes the like" do
        expect(like).to be_valid
        expect do
          command.call
        end.to change(Like, :count).by(-1)
      end

      it "decreases the likes counter by one" do
        resource = like.resource
        expect(Like.count).to eq(1)
        expect do
          command.call
          resource.reload
        end.to change { resource.likes_count }.by(-1)
      end
    end
  end
end
