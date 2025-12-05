// DÉSACTIVÉ TEMPORAIREMENT - Service Worker pour Push Notifications
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
//   static values = {
//     vapidPublicKey: String
//   }
//
//   connect() {
//     if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
//       console.log("Push notifications not supported")
//       return
//     }
//
//     this.registerServiceWorker()
//   }
//
//   async registerServiceWorker() {
//     try {
//       const registration = await navigator.serviceWorker.register("/service-worker.js")
//       console.log("Service Worker registered:", registration.scope)
//
//       await navigator.serviceWorker.ready
//
//       const existingSubscription = await registration.pushManager.getSubscription()
//       if (existingSubscription) {
//         console.log("Already subscribed to push notifications")
//         this.startLocationTracking()
//         return
//       }
//
//       const permission = await Notification.requestPermission()
//       if (permission !== "granted") {
//         console.log("Notification permission denied")
//         return
//       }
//
//       await this.subscribeToPush(registration)
//       this.startLocationTracking()
//     } catch (error) {
//       console.error("Service Worker registration failed:", error)
//     }
//   }
//
//   async subscribeToPush(registration) {
//     if (!this.hasVapidPublicKeyValue || !this.vapidPublicKeyValue) {
//       console.warn("VAPID public key not configured")
//       return
//     }
//
//     try {
//       const subscription = await registration.pushManager.subscribe({
//         userVisibleOnly: true,
//         applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
//       })
//
//       const response = await fetch("/api/push_subscriptions", {
//         method: "POST",
//         headers: { "Content-Type": "application/json" },
//         body: JSON.stringify({
//           endpoint: subscription.endpoint,
//           p256dh_key: btoa(String.fromCharCode(...new Uint8Array(subscription.getKey("p256dh")))),
//           auth_key: btoa(String.fromCharCode(...new Uint8Array(subscription.getKey("auth"))))
//         })
//       })
//
//       if (response.ok) console.log("Push subscription saved")
//     } catch (error) {
//       console.error("Push subscription failed:", error)
//     }
//   }
//
//   startLocationTracking() {
//     if (!("geolocation" in navigator)) return
//
//     this.sendLocation()
//     this.locationInterval = setInterval(() => this.sendLocation(), 30000)
//   }
//
//   async sendLocation() {
//     try {
//       const position = await new Promise((resolve, reject) => {
//         navigator.geolocation.getCurrentPosition(resolve, reject, {
//           enableHighAccuracy: true,
//           timeout: 10000,
//           maximumAge: 30000
//         })
//       })
//
//       await fetch("/api/locations", {
//         method: "POST",
//         headers: { "Content-Type": "application/json" },
//         body: JSON.stringify({
//           latitude: position.coords.latitude,
//           longitude: position.coords.longitude
//         })
//       })
//     } catch (error) {
//       // Silent fail
//     }
//   }
//
//   urlBase64ToUint8Array(base64String) {
//     const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
//     const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
//     const rawData = window.atob(base64)
//     const outputArray = new Uint8Array(rawData.length)
//     for (let i = 0; i < rawData.length; ++i) {
//       outputArray[i] = rawData.charCodeAt(i)
//     }
//     return outputArray
//   }
//
//   disconnect() {
//     if (this.locationInterval) clearInterval(this.locationInterval)
//   }
}
