# Social providers integration

If you want to enable sign up through social providers like Facebook you will need to generate app credentials and store them in one of the following places:

- In the Rails secrets file: `config/secrets.yml`. This configuration will be shared by all tenants.
- In the site configuration (ex. system/organizations/1/edit). This configuration overrides the one in `config/secrets.yml`.

Take into account that for a social provider integration appearing in the organization form, it must also be defined in `config/secrets.yml` (but the values are optional). For example:

```yaml
twitter:
  enabled: false # disabled by default, unless activated in the organization
  api_key:
  api_secret:
```

## Facebook

1. Navigate to [Facebook Developers Page](https://developers.facebook.com/)
1. Follow the "Add a New App" link.
1. Click the "Website" option.
1. Fill in your application name and click "Create New Facebook App ID" button.
1. Fill in the contact email info and category.
1. Validate the captcha.
1. Ignore the source code and fill in the URL field with `https://YOUR_DECIDIM_HOST/users/auth/facebook/callback`
1. Navigate to the application dashboard and copy the APP_ID and APP_SECRET
1. Paste credentials in `config/secrets.yml` or in the organization configuration. Ensure the `enabled` attribute is `true`.

## Twitter

1. Navigate to [Twitter Developers Page](https://dev.twitter.com/)
1. Follow the "My apps" link.
1. Click the "Create New App" button.
1. Fill in the `Name`, `Description` fields.
1. Fill in the `Website` and `Callback URL` fields with the same value. If you are working on a development app you need to use `http://127.0.0.1:3000/` instead of `http://localhost:3000/`.
1. Check the 'Developer Agreement' checkbox and click the 'Create your Twitter application' button.
1. Navigate to the "Keys and Access Tokens" tab and copy the API_KEY and API_SECRET.
1. (Optional) Navigate to the "Permissions" tab and check the "Request email addresses from users" checkbox.
1. Paste credentials in `config/secrets.yml` or in the organization configuration. Ensure the `enabled` attribute is `true`.

## Google

1. Navigate to [Google Developers Page](https://console.developers.google.com)
1. Follow the 'Create projecte' link.
1. Fill in the name of your app.
1. Navigate to the projecte dashboard and click on "Enable API"
1. Click on `Google+ API` and then "Enable"
1. Navigate to the project credentials page and click on `OAuth consent screen`.
1. Fill in the `Product name` field
1. Click on `Credentials` tab and click on "Create credentials" button. Select `OAuth client ID`.
1. Select `Web applications`. Fill in the `Authorized Javascript origins` with your url. Then fill in the `Authorized redirect URIs` with your url and append the path `/users/auth/google_oauth2/callback`.
1. Copy the CLIENT_ID AND CLIENT_SECRET
1. Paste credentials in `config/secrets.yml` or in the organization configuration. Ensure the `enabled` attribute is `true`.

## Custom providers

* You can define your own provider, to allow users from other external applications to login into Decidim.
* The provider should implement an [OmniAuth](https://github.com/omniauth/omniauth) strategy.
* You can use any of the [existing OnmiAuth strategies](https://github.com/omniauth/omniauth/wiki/List-of-Strategies).
* Or you can create a new strategy, as the [Decidim OmniAuth Strategy](https://github.com/decidim/omniauth-decidim). This strategy allow users from a Decidim instance to login in other Decidim instance. For example, this strategy is used to allow [decidim.barcelona](https://decidim.barcelona) users to log into [meta.decidim.barcelona](https://meta.decidim.barcelona).
* Once you have defined your strategy, you can configure it in the `config/secrets.yml` or in the organization configuration, as it is done for the built-in providers.
* By default, Decidim will search in its icons library for an icon named as the provider. You can change this adding an `icon` or `icon_path` attribute to the provider configuration. The `icon` attribute sets the icon name to look for in the Decidim's icons library. The `icon_path` attribute sets the route to the image that should be used.
* Here is an example of the configuration section for the Decidim strategy, using an icon located on the application's `app/assets/images` folder:

```yaml
    decidim:
      enabled: true
      client_id: <%= ENV["DECIDIM_CLIENT_ID"] %>
      client_secret: <%= ENV["DECIDIM_CLIENT_SECRET"] %>
      site_url: <%= ENV["DECIDIM_SITE_URL"] %>
      icon_path: decidim-logo.svg
```
