# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe Post do
    subject { post }

    let(:current_organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, organization: current_organization) }
    let(:participatory_process) { create :participatory_process, organization: current_organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "blogs" }
    let(:post) { create(:post, component: current_component, author: current_user) }

    include_examples "has component"
    include_examples "resourceable"

    it { is_expected.to be_valid }

    context "without a component" do
      let(:post) { build :post, component: nil, author: current_user }

      it { is_expected.not_to be_valid }
    end

    context "without a valid component" do
      let(:post) { build :post, component: build(:component, manifest_name: "proposals"), author: current_user }

      it { is_expected.not_to be_valid }
    end

    context "without a valid author" do
      let(:other_author) { create(:user) }
      let(:post) { build :post, component: current_component, author: other_author }

      it { is_expected.not_to be_valid }
    end

    it "has an associated component" do
      expect(post.component).to be_a(Decidim::Component)
    end

    describe "#visible?" do
      subject { post.visible? }

      context "when component is not published" do
        before do
          allow(post.component).to receive(:published?).and_return(false)
        end

        it { is_expected.not_to be_truthy }
      end

      context "when participatory space is visible" do
        before do
          allow(post.component.participatory_space).to receive(:visible?).and_return(false)
        end

        it { is_expected.not_to be_truthy }
      end
    end

    describe "#endorsed_by?" do
      let(:user) { create(:user, organization: subject.organization) }

      context "with User endorsement" do
        it "returns false if the post is not endorsed by the given user" do
          expect(subject).not_to be_endorsed_by(user)
        end

        it "returns true if the post is not endorsed by the given user" do
          create(:endorsement, resource: subject, author: user)
          expect(subject).to be_endorsed_by(user)
        end
      end

      context "with Organization endorsement" do
        let!(:user_group) { create(:user_group, verified_at: Time.current, organization: user.organization) }
        let!(:membership) { create(:user_group_membership, user: user, user_group: user_group) }

        before { user_group.reload }

        it "returns false if the post is not endorsed by the given organization" do
          expect(subject).not_to be_endorsed_by(user, user_group)
        end

        it "returns true if the post is not endorsed by the given organization" do
          create(:endorsement, resource: subject, author: user, user_group: user_group)
          expect(subject).to be_endorsed_by(user, user_group)
        end
      end
    end

    describe "#users_to_notify_on_comment_created" do
      let!(:follows) { create_list(:follow, 3, followable: subject) }
      let(:followers) { follows.map(&:user) }
      let(:participatory_space) { subject.component.participatory_space }
      let(:organization) { participatory_space.organization }

      context "when creating new comment" do
        it "returns the followers" do
          expect(subject.users_to_notify_on_comment_created).to match_array(followers)
        end
      end
    end
  end
end
