# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Forms
    # This is the engine that runs on the public interface of `decidim-forms`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Forms

      initializer "decidim_forms.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Forms::Engine.root}/app/cells")
      end

      initializer "decidim_forms.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_forms.authorization_transfer" do
        Decidim::AuthorizationTransfer.subscribe do |authorization, target_user|
          # rubocop:disable Rails/SkipsModelValidations
          Decidim::Forms::Answer.where(user: authorization.user).update_all(
            decidim_user_id: target_user.id
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
