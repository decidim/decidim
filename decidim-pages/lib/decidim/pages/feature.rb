Decidim.register_feature(:pages) do |feature|
  feature.component :page do |component|
    component.engine = Decidim::Pages::Engine
    component.admin_engine = Decidim::Pages::AdminEngine

    component.on(:create) do |instance|
      Decidim::Pages::CreatePage.call(instance) do
        on(:error) { raise "Can't create page" }
      end
    end

    component.on(:destroy) do |instance|
      Decidim::Pages::DestroyPage.call(instance) do
        on(:error) { raise "Can't destroy page" }
      end
    end
  end
end
