# Decidim::Comments

The Comments module adds the ability to include comments to any resource which can be commentable by users.

## Usage

The Comments component is exposed as a Rails helper:

```ruby
<%= comments_for @commentable %>
```
 
In order to use the helper in your templates you need to include the comments helpers in your application helper:

```ruby
include Decidim::Comments::CommentsHelper
```

Finally, add the comments javascript module via Sprockets like this:

```javascript
//= require decidim/comments/comments
```

## Installation

Add this line to your application's Gemfile.

```ruby
gem 'decidim-comments'
```

And then execute:
```bash
$ bundle
```

## Contributing
See [Decidim](https://github.com/AjuntamentdeBarcelona/decidim).

## License
See [Decidim](https://github.com/AjuntamentdeBarcelona/decidim).
