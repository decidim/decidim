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

#### Developing React components

You need to execute `yarn start` in a separate terminal, in the `decidim` root folder while you are developing this module. When you are finished you can build the project for production like this: `yarn build:prod`. We are checking in the bundle into the repository.

#### Run tests

You can execute `yarn test` to run the javascript test suite or you can run `yarn test:watch` to listen for file changes.

#### GraphQL schema and Typescript

Since we are using Typescript we can generate interfaces and types from our schema using the following command:

```bash
  yarn run graphql:generate_schema_types
```

This command will create a file called `app/frontend/support/schema.ts` that can be used to strict type checking in our components.

## Contributing
See [Decidim](https://github.com/AjuntamentdeBarcelona/decidim).

## License
See [Decidim](https://github.com/AjuntamentdeBarcelona/decidim).
