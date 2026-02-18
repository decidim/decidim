# frozen_string_literal: true

module Decidim
  module Dev
    class OfficialAuthorPresenter
      def name
        self.class.name
      end

      def nickname
        "decidim_dev_official"
      end

      def deleted?
        false
      end

      def respond_to_missing?(*)
        true
      end

      def method_missing(method, *args)
        if method.to_s.ends_with?("?")
          false
        elsif [:avatar_url, :profile_path, :badge, :followers_count, :cache_key_with_version].include?(method)
          ""
        else
          super
        end
      end
    end
  end
end
