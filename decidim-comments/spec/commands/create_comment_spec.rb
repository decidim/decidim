# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      include_context "when creating a comment"
      it_behaves_like "create comment"
    end
  end
end
