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
bundle
```

## How to contribute

The technology stack used in this module is the following:

For the backend side:

- Ruby on Rails
- GraphQL

For the frontend side:

- Typescript (introduced in #1001)
- React
- Apollo

The frontend code can be found in the folder `app/frontend` instead of `app/assets`. We are using Webpack to build the React application so we are keeping the React files in a separate folder and then including the `bundle.js` file using sprockets as usual.

### Developing React components

You need to execute `npm start` in a separate terminal, in the `decidim` root folder while you are developing this module. When you are finished you can build the project for production like this: `npm run build:prod`. We are checking in the bundle into the repository.

#### Run tests

You can execute `npm test` to run the javascript test suite or you can run `npm run test:watch` to listen for file changes.

#### GraphQL schema and Typescript

Since we are using Typescript we can generate interfaces and types from our schema using the following command:

```bash
npm run graphql:generate_schema_types
```

This command will create a file called `app/frontend/support/schema.ts` that can be used to strict type checking in our components.

In order for this to work your Rails server must be running at `localhost:3000`, if you're using a different host you can set it with `DECIDIM_HOST`:

```bash
DECIDIM_HOST=myhost:3000 npm run graphql:generate_schema_types
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
