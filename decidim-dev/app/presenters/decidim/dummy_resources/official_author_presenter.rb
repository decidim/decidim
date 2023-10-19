# frozen_string_literal: true

module Decidim
  module DummyResources
    class OfficialAuthorPresenter
      def name
        self.class.name
      end

      def nickname
        Decidim::UserBaseEntity.nicknamize(name)
      end

      def deleted?
        false
      end

      def visible?
        true
      end

      def respond_to_missing?(method, _include_private = false)
        return false if method == :__getobj__

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
