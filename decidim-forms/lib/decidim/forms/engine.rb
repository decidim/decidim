# frozen_string_literal: true

module Decidim
  module Forms
    # This is the engine that runs on the public interface of `decidim-forms`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Forms
    end
  end
end
