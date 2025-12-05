import consumer from "./consumer"

// This channel will be initialized by the mapbox controller
// Export the subscription creator for use in other controllers
export function subscribeToPings(callbacks) {
  return consumer.subscriptions.create("PingsChannel", {
    connected() {
      console.log("Connected to PingsChannel")
    },

    disconnected() {
      console.log("Disconnected from PingsChannel")
    },

    received(data) {
      if (data.action === "create" && callbacks.onPingCreated) {
        callbacks.onPingCreated(data.ping)
      } else if (data.action === "expire" && callbacks.onPingExpired) {
        callbacks.onPingExpired(data.ping_id)
      }
    }
  })
}
