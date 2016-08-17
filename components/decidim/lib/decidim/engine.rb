module Decidim
  class Engine < ::Rails::Engine
    isolate_namespace Decidim

    initializer 'decidim.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Decidim::LayoutHelper
      end
    end
  end
end
