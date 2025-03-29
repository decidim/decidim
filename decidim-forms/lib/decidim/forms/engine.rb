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
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:forms) do |transfer|
            transfer.move_records(Decidim::Forms::Response, :decidim_user_id)
          end
        end
      end
    end
  end
end
