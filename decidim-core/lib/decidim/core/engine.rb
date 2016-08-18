module Decidim
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Decidim
      engine_name 'decidim'

      initializer 'decidim.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper
        end
      end
    end
  end
end
