# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  describe ".lazy_relation" do
    let(:organization) { create(:organization) }
    let(:component) { create(:component, :published, manifest_name: "dummy", organization:) }

    # Initiatives are commentable but do not define a component association, so the batch
    # mixes a componentless root with a component-backed resource.
    let!(:resources) { [create(:initiative, organization:), create(:dummy_resource, component:)] }

    include_examples "action log lazy relation"

    it "loads the comments of the roots without a component association" do
      comments = action_logs.map(&:resource_lazy)

      expect(comments).to all(be_a(Decidim::Comments::Comment))

      initiative_comment = comments.find { |comment| comment.root_commentable.is_a?(Decidim::Initiative) }
      dummy_comment = comments.find { |comment| comment.root_commentable.is_a?(Decidim::Dev::DummyResource) }

      expect(Decidim::Initiative.reflect_on_association(:component)).to be_nil
      expect(initiative_comment).to be_present
      expect(initiative_comment.association(:root_commentable).loaded?).to be(true)
      expect(dummy_comment.association(:root_commentable).loaded?).to be(true)
      expect(dummy_comment.root_commentable.association(:component).loaded?).to be(true)
    end

    it "eager loads the organization for the roots without a component association" do
      comments = action_logs.map(&:resource_lazy)

      initiative_comment = comments.find { |comment| comment.root_commentable.is_a?(Decidim::Initiative) }

      expect(initiative_comment).to be_present
      expect(initiative_comment.root_commentable.association(:organization).loaded?).to be(true)
    end

    it "eager loads the commentable ancestor chain for a reply to a root without a component association" do
      initiative = resources.first
      parent = create(:comment, commentable: initiative)
      reply = create(:comment, commentable: parent)
      log = create(:action_log, action: "create", visibility: "all", resource: reply, organization:, participatory_space: reply.participatory_space)

      comment = log.resource_lazy

      # The associations are checked before being read; reading `commentable` would
      # lazily load it and the assertions would pass without the ancestor preload.
      expect(comment.association(:commentable).loaded?).to be(true)
      parent = comment.association(:commentable).target
      expect(parent.association(:commentable).loaded?).to be(true)
      root = parent.association(:commentable).target
      expect(root.association(:organization).loaded?).to be(true)
    end
  end
end
