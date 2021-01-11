# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentUpvotedEvent do
  let(:event_name) { "decidim.events.comments.comment_upvoted" }
  let(:weight) { 1 }

  it_behaves_like "a comment voted event"
end
