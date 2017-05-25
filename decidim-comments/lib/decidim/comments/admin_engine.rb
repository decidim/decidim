# frozen_string_literal: true

module Decidim
  module Comments
    # This is the engine that runs on the public interface of `decidim-comments`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Comments::Admin

      paths["db/migrate"] = nil

      initializer "decidim_comments.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += ["Decidim::Comments::Abilities::AdminUser"]
          config.admin_abilities += ["Decidim::Comments::Abilities::ProcessAdminUser"]
        end
      end

      def load_seed
        nil
      end
    end
  end
end
