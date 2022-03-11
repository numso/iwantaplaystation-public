# Checker

We gonna get us a ps5

## Setting up sms

You'll first need a google refresh token. You can follow the guide here: https://developers.google.com/identity/protocols/oauth2. Make sure your oauth app has access to send emails. If you add your client id and secret to config.exs then you can use the helper functions at the end of Checker.GmailAuth to help generate your refresh token.

Put your refresh token in config.exs. Then fill out the variables and uncomment the texting code in Checker.Notify.

## Setting up slack

1. Create a slack app and get a webhook URL: https://api.slack.com/messaging/webhooks
2. Uncomment the module attribute and add your URL to `lib/checker/notify.ex` line 6
3. Uncomment `lib/checker/notify.ex` lines 14 and 21

## Updating when messages send

That's all in should_send/0 in Checker.Notify

## Updating checkers

You can change what URLs you're scraping and what you're looking for in them inside Checker.SiteChecker

You can turn each checker off completely by commenting them out in Checker.Application
