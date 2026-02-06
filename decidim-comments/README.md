# decidim-comments

The Comments module adds the ability to include comments to any resource which can be commentable by users.

This is a module oriented for developers, as a building block to be used by other modules.

## Installation

Add this line to your module's gemspec:

```ruby
s.add_dependency "decidim-comments", Decidim::YourModule.version
```

And then execute:

```bash
bundle
```

## Usage on another modules

The Comments component is exposed as a Rails helper:

```ruby
<%= comments_for @commentable %>
```

In order to use the helper in your templates you need to include the comments helpers in your application helper:

```ruby
include Decidim::Comments::CommentsHelper
```

Finally, add the comments javascript module like this:

```javascript
import "src/decidim/comments/comments";
```

## How to contribute

The technology stack used in this module is the following:

For the backend side:

- Ruby on Rails
- GraphQL

For the frontend side:

- React
- Apollo

The frontend code can be found in the folder `app/packs.

### Developing React components

You need to execute `npm start` in a separate terminal, in the `decidim` root folder while you are developing this module. When you are finished you can build the project for production like this: `npm run build:prod`. We are checking in the bundle into the repository.

#### Run tests

You can execute `npm test` to run the javascript test suite or you can run `npm run test:watch` to listen for file changes.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
