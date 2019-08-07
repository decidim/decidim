# Followers

## Create followers from comment authors

Run the following script to make all comment authors follow the commented resource:

```ruby
Decidim::Comments::Comment.includes(:author, :root_commentable).find_each do |comment|
  begin
    Decidim::Follow.create!(followable: comment.root_commentable, user: comment.author)
  rescue
  end
end; p 1
```

## Create followers from resource authors

Run the following script to make all resource authors follow the resource:

```ruby
Decidim.component_manifests.each do |component_manifest|
  component_manifest.resource_manifests.each do |resource_manifest|
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

