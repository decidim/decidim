# Create followers from resource authors

Run the following script to make all resource authors follow the resource:

```ruby
Decidim.feature_manifests.each do |feature_manifest|
  feature_manifest.resource_manifests.each do |resource_manifest|
    klass = resource_manifest.model_class_name.constantize
    next unless klass.included_modules.include? Decidim::Authorable

    klass.includes(:author).find_each do |resource|
      begin
        Decidim::Follow.create!(followable: resource, user: resource.author) if resource.author.present?
      rescue
      end
    end
  end
end; p 1
```
