# frozen_string_literal: true

require "spec_helper"

# Shared examples for the BatchLoader query used by Decidim::ActionLog#resource_lazy.
#
# The resources are polymorphic, so the associations needed to check whether an
# activity is visible (`ActionLog#visible_for?`) have to be eager loaded through the
# lazy relation. These examples check that the component is eager loaded for the
# resources of each component module.
shared_examples_for "action log lazy relation" do
  let!(:action_logs) do
    resources.map do |resource|
      comment = create(:comment, commentable: resource)

      create(
        :action_log,
        action: "create",
        visibility: "all",
        resource: comment,
        organization: resource.organization,
        participatory_space: comment.participatory_space
      )
    end
  end

  it "eager loads the component through the polymorphic root_commentable" do
    comments = action_logs.map(&:resource_lazy)

    expect(comments).to all(be_a(Decidim::Comments::Comment))
    comments.each do |comment|
      expect(comment.association(:root_commentable).loaded?).to be(true)

      # Roots without a component association (e.g. `Decidim::Initiative`) are skipped by
      # the preloader, so the component is only expected on the roots that define it.
      next unless comment.root_commentable.class.reflect_on_association(:component)

      expect(comment.root_commentable.association(:component).loaded?).to be(true)
    end
  end
end

# For the resources that are not commentable there is no comment to traverse, so the
# component is expected to be eager loaded directly on the resource.
shared_examples_for "action log lazy relation for non commentable resources" do
  let!(:action_logs) do
    resources.map do |resource|
      create(
        :action_log,
        action: "create",
        visibility: "all",
        resource:,
        organization: resource.organization,
        participatory_space: resource.participatory_space
      )
    end
  end

  it "eager loads the component for the resource" do
    resources = action_logs.map(&:resource_lazy)

    expect(resources).to all(be_a(resource_class))
    resources.each do |resource|
      expect(resource.association(:component).loaded?).to be(true)
    end
  end
end
