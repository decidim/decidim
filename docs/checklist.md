# Checklist

As a technopolitical project, Decidim needs several things to work. This is a non comprehensive list that serves as a general recommendation of what things you need to have it working with the best practices:

## Technological

1. Choose a **domain** for your application. Some typical names involve "Participation" or "Decision" conjugations.

1. Choose which **languages** do you want for your application. In case that your language isn't supported you should translate it on [Crowdin](https://crowdin.com/project/decidim).

1. Customize the [**look and feel**](customization/styles.md) (colors, pictures, fonts, etc).

1. Configure **SSL**. We recommend using at least [Let's Encrypt](https://letsencrypt.org/) for a minimum security. You should also check that there's an enforced redirection from HTTP to HTTPS on your web server.

1. Configure your **SMTP** server.

1. Setup the **geolocation** service. We recommend using [Here Maps](https://developer.here.com/), but you can use other kind of tiling server compatible with [Open Street Maps](https://www.openstreetmap.org/).

1. Setup an **analytics** server. For better compliance with Decidim Social Contract, we recommend using [Matomo](https://matomo.org/).

1. Setup **backup** on your server. The most important things to save are the `public/uploads` and the database.

1. Decide and implement which kind of **[Authorization](customization/authorizations.md)** you're going to use.

1. Comply with our License (Affero GPL 3) and **publish your code** to [GitHub](http://github.com) or wherever you want.

1. Review your **decidim initializer** on your application (config/initializers/decidim.rb).

1. Configure your [**ActiveJob**](services/activejob.md) background queue.

1. If you want, configure your [**social providers**](services/social_providers.md) to enable login using external applications.

1. Check that you don't have any **default users, emails and passwords**, neither on the admin or on the system panel.

## Contents

1. Ideally you'll have a **Team** formed with experts on IT, Communication, Participation, Design and Law.

1. Texts for at least, **terms of use, privacy policy and frequently asked questions**. To show the "Terms and conditions" body text in the "Sign Up Form", it is a requirement that the slug of this page to be equal `terms-and-conditions`.

1. Comply with your current **legal requirements**, like to registrate your privacy policy with the autorities (eg LOPD on Spain).

1. Fill the **Participatory Processes Configuration Form** to prepare your Participatory Process for Decidim.

1. Read the **[Administration manual](https://decidim.org/docs/)**.

1. Participate on **[MetaDecidim](http://meta.decidim.barcelona)**.

1. Read the Decidim **[Social Contract](https://decidim.org/contract/)**.
