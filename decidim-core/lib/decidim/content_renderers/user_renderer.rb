# frozen_string_literal: true

module Decidim
  module ContentRenderers
    class UserRenderer < BaseRenderer
      GLOBAL_ID_REGEX = %r{gid://.*/Decidim::User/\d+}

      # Replaces any @user:id with a link to the profile it it exists.
      def render
        content.gsub(GLOBAL_ID_REGEX) do |user_gid|
          begin
            user = GlobalID::Locator.locate(user_gid)
            Decidim::UserPresenter.new(user).display_mention
          rescue ActiveRecord::RecordNotFound => _ex
            ""
          end
        end
      end
    end
  end
end
