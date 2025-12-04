# Web Push VAPID configuration
# Generate keys with: bundle exec rails runner "puts WebPush.generate_key.to_hash"

# VAPID keys are passed directly to WebPush.payload_send() in SendPushNotificationJob
# No global configuration needed - the gem doesn't have a configure method

Rails.application.config.web_push = {
  vapid_public_key: ENV["VAPID_PUBLIC_KEY"],
  vapid_private_key: ENV["VAPID_PRIVATE_KEY"],
  vapid_subject: "mailto:#{ENV.fetch('VAPID_SUBJECT', 'contact@pingsafe.app')}"
}
