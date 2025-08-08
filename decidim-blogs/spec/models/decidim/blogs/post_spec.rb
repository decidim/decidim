# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe Post do
    subject { post }

    let(:current_organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, organization: current_organization) }
    let(:participatory_process) { create(:participatory_process, organization: current_organization) }
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "blogs") }
    let(:post) { create(:post, component: current_component, author: current_user, published_at:) }
    let(:published_at) { nil }

    include_examples "likeable"
    include_examples "has component"
    include_examples "resourceable"

    it { is_expected.to be_valid }
    it { is_expected.to act_as_paranoid }

    context "without a component" do
      let(:post) { build(:post, component: nil, author: current_user) }

      it { is_expected.not_to be_valid }
    end

    context "without a valid component" do
      let(:post) { build(:post, component: build(:component, manifest_name: "proposals"), author: current_user) }

      it { is_expected.not_to be_valid }
    end

    context "without a valid author" do
      let(:other_author) { create(:user) }
      let(:post) { build(:post, component: current_component, author: other_author) }

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
