# frozen_string_literal: true

module Decidim
  # A module with all the methods necessary for adding the resource's author as a follower
  module FollowResource
    private

    def create_follow_form_resource(resource, user)
      follow_form = Decidim::FollowForm.from_params(followable_gid: resource.to_signed_global_id.to_s).with_context(current_user: user)
      Decidim::CreateFollow.call(follow_form, user)
    end
  end
end
