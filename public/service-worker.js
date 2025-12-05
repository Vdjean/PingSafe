// PingSafe Service Worker for Push Notifications

// self.addEventListener("install", (event) => {
//   console.log("Service Worker installed")
//   self.skipWaiting()
// })

// self.addEventListener("activate", (event) => {
//   console.log("Service Worker activated")
//   event.waitUntil(clients.claim())
// })

// // Handle push notifications
// self.addEventListener("push", (event) => {
//   if (!event.data) return

//   const data = event.data.json()

//   const options = {
//     body: data.body,
//     icon: "/apple-touch-icon.png",
//     badge: "/apple-touch-icon.png",
//     vibrate: [200, 100, 200],
//     tag: `ping-${data.ping_id}`,
//     renotify: true,
//     data: {
//       url: data.url || "/"
//     }
//   }

//   event.waitUntil(
//     self.registration.showNotification(data.title || "Alerte PingSafe", options)
//   )
// })

// // Handle notification click
// self.addEventListener("notificationclick", (event) => {
//   event.notification.close()

//   const url = event.notification.data?.url || "/"

//   event.waitUntil(
//     clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
//       // If a window is already open, focus it
//       for (const client of clientList) {
//         if (client.url.includes(self.location.origin) && "focus" in client) {
//           client.navigate(url)
//           return client.focus()
//         }
//       }
//       // Otherwise open a new window
//       if (clients.openWindow) {
//         return clients.openWindow(url)
//       }
//     })
//   )
// })
