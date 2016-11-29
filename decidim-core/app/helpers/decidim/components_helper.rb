module Decidim
  module ComponentsHelper
    def component_path(component)
      decidim.public_send("#{component.manifest.name}_component_path",
                  component.participatory_process,
                  component)
    end

    def manage_component_path(component)
      decidim.public_send("manage_#{component.manifest.name}_component_path",
                  component.participatory_process,
                  component)
    end
  end
end
