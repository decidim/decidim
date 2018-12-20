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
  end
end
