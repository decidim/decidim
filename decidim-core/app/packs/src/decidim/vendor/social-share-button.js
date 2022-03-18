/* eslint-disable complexity, default-case, no-param-reassign, consistent-return */

/*
 *
 * Social Share Button
 *
 * Copyright (c) <2012> <Jason Lee> - The MIT license
 * Originally copied fom https://github.com/huacnlee/social-share-button
 * Transformed from Coffescript to Javascipt with decaffeintate
 *
 * We've copied itlocally so it works with webpacker
 *
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
window.SocialShareButton = {
  openUrl(url, width, height) {
    if (width === null) {
      width = 640;
    }
    if (height === null) {
      height = 480;
    }
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height * 0.3) - (height / 2);
    const opt = `width=${width},height=${height},left=${left},top=${top},menubar=no,status=no,location=no`;
    window.open(url, "popup", opt);
    return false;
  },

  share(el) {
    if (el.getAttribute === null) {
      el = document.querySelector(el);
    }

    const site = el.getAttribute("data-site");
    const appkey = el.getAttribute("data-appkey") || "";
    const $parent = el.parentNode;
    let title = encodeURIComponent(el.getAttribute(`data-${site}-title`) || $parent.getAttribute("data-title") || "");
    const img = encodeURIComponent($parent.getAttribute("data-img") || "");
    let url = encodeURIComponent($parent.getAttribute("data-url") || "");
    const via = encodeURIComponent($parent.getAttribute("data-via") || "");
    const desc = encodeURIComponent($parent.getAttribute("data-desc") || " ");

    // tracking click events if google analytics enabled
    const ga = window[window.GoogleAnalyticsObject || "ga"];
    if (typeof ga === "function") {
      ga("send", "event", "Social Share Button", "click", site);
    }

    if (url.length === 0) {
      url = encodeURIComponent(location.href);
    }
    switch (site) {
    case "email":
      location.href = `mailto:?subject=${title}&body=${url}`;
      break;
    case "weibo":
      this.openUrl(`http://service.weibo.com/share/share.php?url=${url}&type=3&pic=${img}&title=${title}&appkey=${appkey}`, 620, 370);
      break;
    case "twitter": {
      let hashtags = encodeURIComponent(el.getAttribute(`data-${site}-hashtags`) || $parent.getAttribute("data-hashtags") || "");
      let viaStr = "";
      if (via.length > 0) {
        viaStr = `&via=${via}`;
      }
      this.openUrl(`https://twitter.com/intent/tweet?url=${url}&text=${title}&hashtags=${hashtags}${viaStr}`, 650, 300);
      break;
    }
    case "douban":
      this.openUrl(`http://shuo.douban.com/!service/share?href=${url}&name=${title}&image=${img}&sel=${desc}`, 770, 470);
      break;
    case "facebook":
      this.openUrl(`http://www.facebook.com/sharer/sharer.php?u=${url}`, 555, 400);
      break;
    case "qq":
      this.openUrl(`http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=${url}&title=${title}&pics=${img}&summary=${desc}&site=${appkey}`);
      break;
    case "google_bookmark":
      this.openUrl(`https://www.google.com/bookmarks/mark?op=edit&output=popup&bkmk=${url}&title=${title}`);
      break;
    case "delicious":
      this.openUrl(`https://del.icio.us/save?url=${url}&title=${title}&jump=yes&pic=${img}`);
      break;
    case "pinterest":
      this.openUrl(`http://www.pinterest.com/pin/create/button/?url=${url}&media=${img}&description=${title}`);
      break;
    case "linkedin":
      this.openUrl(`https://www.linkedin.com/shareArticle?mini=true&url=${url}&title=${title}&summary=${desc}`);
      break;
    case "xing":
      this.openUrl(`https://www.xing.com/spi/shares/new?url=${url}`);
      break;
    case "vkontakte":
      this.openUrl(`http://vk.com/share.php?url=${url}&title=${title}&image=${img}`);
      break;
    case "odnoklassniki":
      this.openUrl(`https://connect.ok.ru/offer?url=${url}&title=${title}&description=${desc}&imageUrl=${img}`);
      break;
    case "wechat":
      if (!window.SocialShareWeChatButton) {
        throw new Error("You should require social-share-button/wechat to your application.js");
      }
      window.SocialShareWeChatButton.qrcode({
        url: decodeURIComponent(url),
        header: el.getAttribute("title"),
        footer: el.getAttribute("data-wechat-footer")
      });
      break;

    case "tumblr": {
      let getTumblrExtra = function(param) {
        const cutomData = el.getAttribute(`data-${param}`);
        if (cutomData) {
          return encodeURIComponent(cutomData);
        }
      };

      let tumblrParams = function() {
        const path = getTumblrExtra("type") || "link";

        const params = (() => {
          switch (path) {
          case "text": {
            title = getTumblrExtra("title") || title;
            return `title=${title}`;
          }
          case "photo": {
            title = getTumblrExtra("caption") || title;
            let source = getTumblrExtra("source") || img;
            return `caption=${title}&source=${source}`;
          }
          case "quote": {
            let quote = getTumblrExtra("quote") || title;
            let source = getTumblrExtra("source") || "";
            return `quote=${quote}&source=${source}`;
          }
          // actually, it's a link clause
          default: {
            title = getTumblrExtra("title") || title;
            url = getTumblrExtra("url") || url;
            return `name=${title}&url=${url}`;
          }} })();

        return `/${path}?${params}`;
      };

      this.openUrl(`http://www.tumblr.com/share${tumblrParams()}`);
      break;
    }
    case "reddit":
      this.openUrl(`http://www.reddit.com/submit?url=${url}&newwindow=1`, 555, 400);
      break;
    case "hacker_news":
      this.openUrl(`http://news.ycombinator.com/submitlink?u=${url}&t=${title}`, 770, 500);
      break;
    case "telegram":
      this.openUrl(`https://telegram.me/share/url?text=${title}&url=${url}`);
      break;
    case "whatsapp_app": {
      let whatsappAppUrl = `whatsapp://send?text=${title}%0A${url}`;
      window.open(whatsappAppUrl, "_top");
      break;
    }
    case "whatsapp_web":
      this.openUrl(`https://web.whatsapp.com/send?text=${title}%0A${url}`);
      break;
    }
    return false;
  }
};
