# frozen_string_literal: true

module Decidim
  # This cell renders the author of a resource. It is intended to be used
  # below resource titles to indicate its authorship & such, and is intended
  # for resources that have a single author.
  class AuthorBoxCell < Decidim::ViewModel
    include LayoutHelper
    include Messaging::ConversationHelper

    def show
      render
    end

    delegate :user_signed_in?, :current_user, to: :parent_controller

    def author_box_classes
      (["author-data"] + options[:extra_classes].to_a).join(" ")
    end
  end
end
