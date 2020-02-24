# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Followable do
    subject { resource }

    let(:resource) { create(:dummy_resource) }

    describe "followers" do
      let!(:follow) { create(:follow, followable: resource) }

      it "returns the users following the resource" do
        expect(subject.followers).to include(follow.user)
      end

      context "when the resource doesn't have a participatory space" do
        let(:resource) { create(:user) }

        it "returns their followers" do
          expect(subject.followers).to include(follow.user)
        end
      end

      context "when the participatory space has also followers" do
        let!(:space_follow) { create(:follow, followable: resource.participatory_space) }

        it "includes them too" do
          expect(subject.followers.count).to eq(2)
          expect(subject.followers).to include(follow.user)
          expect(subject.followers).to include(space_follow.user)
        end

        context "when the user follows the space and resource" do
          let!(:space_follow) { create(:follow, followable: resource.participatory_space, user: follow.user) }

          it "is included only once" do
            expect(subject.followers.count).to eq(1)
            expect(subject.followers).to include(follow.user)
          end
        end
      end
    end
  end
end
