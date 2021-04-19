# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentDownvotedEvent do
  let(:event_name) { "decidim.events.comments.comment_downvoted" }
  let(:weight) { -1 }

  it_behaves_like "a comment voted event"
end
