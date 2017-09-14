# Create followers from comment authors

Run the following script to make all comment authors follow the commented resource:

```ruby
Decidim::Comments::Comment.find_each do |comment|
  begin
    Decidim::Follow.create!(followable: comment.root_commentable, user: comment.author)
  rescue
  end
end; p 1
```
