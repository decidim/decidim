# Social providers integration

If you want to enable sign up through social providers like Facebook you will need to generate app credentials and write them into the Rails secrets file: `config/secrets.yml`.

## Facebook

1. Navigate to [Facebook Developers Page](https://developers.facebook.com/)
2. Follow the "Add a New App" link.
3. Click the "Website" option.
4. Fill in your application name and click "Create New Facebook App ID" button.
5. Fill in the contact email info and category.
6. Validate the captcha.
7. Ignore the source code and fill in the URL field.
8. Navigate to the application dashboard and copy the APP_ID and APP_SECRET
9. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.

## Twitter

1. Navigate to [Twitter Developers Page](https://dev.twitter.com/)
2. Follow the "My apps" link.
3. Click the "Create New App" button.
4. Fill in the `Name`, `Description` fields. 
5. Fill in the `Website` and `Callback URL` fields with the same value. If you are working on a development app you need to use `http://127.0.0.1:3000/` instead of `http://localhost:3000/`.
5. Check the 'Developer Agreement' checkbox and click the 'Create your Twitter application' button.
6. Navigate to the "Keys and Access Tokens" tab and copy the API_KEY and API_SECRET.
8. (Optional) Navigate to the "Permissions" tab and check the "Request email addresses from users" checkbox.
9. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.

## Google

1. Navigate to [Google Developers Page](https://console.developers.google.com)
2. Follow the 'Create projecte' link.
3. Fill in the name of your app.
4. Navigate to the projecte dashboard and click on "Enable API"
5. Click on `Google+ API` and then "Enable"
6. Navigate to the project credentials page and click on `OAuth consent screen`.
7. Fill in the `Product name` field
8. Click on `Credentials` tab and click on "Create credentials" button. Select `OAuth client ID`.
9. Select `Web applications`. Fill in the `Authorized Javascript origins` with your url. Then fill in the `Authorized redirect URIs` with your url and append the path `/users/auth/google_oauth2/callback`.
10. Copy the CLIENT_ID AND CLIENT_SECRET
11. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.