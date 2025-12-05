import { Controller } from "@hotwired/stimulus"
import { subscribeToPings } from "channels/pings_channel"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    accessToken: String,
    pings: Array,
    currentUserId: Number
  }

  connect() {
    if (typeof mapboxgl === "undefined") {
      console.error("Mapbox GL JS not loaded")
      return
    }

    mapboxgl.accessToken = this.accessTokenValue

    // Store markers by ping ID for easy removal
    this.markers = new Map()
    this.expiryTimers = new Map()

    // Default to Paris center
    const defaultCenter = [2.3522, 48.8566]
    const defaultZoom = 13

    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v12",
      center: defaultCenter,
      zoom: defaultZoom
    })

    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl(), "top-right")

    // Add geolocate control
    this.geolocateControl = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true,
      showUserHeading: true
    })
    this.map.addControl(this.geolocateControl, "top-right")

    // Trigger geolocation and add markers on map load
    this.map.on("load", () => {
      this.geolocateControl.trigger()
      this.addPingMarkers()
      this.subscribeToChannel()
    })
  }

  subscribeToChannel() {
    this.subscription = subscribeToPings({
      onPingCreated: (ping) => this.addSingleMarker(ping),
      onPingExpired: (pingId) => this.removeMarker(pingId)
    })
  }

  addPingMarkers() {
    if (!this.hasPingsValue || this.pingsValue.length === 0) return

    this.pingsValue.forEach(ping => {
      this.addSingleMarker(ping)
    })
  }

  addSingleMarker(ping) {
    // Don't add duplicate markers
    if (this.markers.has(ping.id)) return

    // Check if ping belongs to current user (different color)
    const isOwnPing = this.hasCurrentUserIdValue && ping.user_id === this.currentUserIdValue
    const markerColor = isOwnPing ? "#1e3a5f" : "#e63946" // Blue for own, red for others

    // Create custom marker element with fox image
    const el = document.createElement("div")
    el.className = "ping-marker"
    el.style.width = "50px"
    el.style.height = "50px"
    el.style.backgroundImage = "url('/assets/fox-pin-full.png')"
    el.style.backgroundSize = "contain"
    el.style.backgroundRepeat = "no-repeat"
    el.style.backgroundPosition = "center"
    el.style.cursor = "pointer"

    // Create popup
    const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(`
      <div class="ping-popup">
        <strong>${ping.comment || "Signalement"}</strong>
        <br>
        <small>${ping.date || ""}</small>
      </div>
    `)

    // Add marker to map
    const marker = new mapboxgl.Marker(el)
      .setLngLat([parseFloat(ping.longitude), parseFloat(ping.latitude)])
      .setPopup(popup)
      .addTo(this.map)

    // Store marker reference
    this.markers.set(ping.id, marker)

    // Set up client-side expiry timer if expires_at is provided
    if (ping.expires_at) {
      const expiresAt = new Date(ping.expires_at)
      const now = new Date()
      const timeUntilExpiry = expiresAt - now

      if (timeUntilExpiry > 0) {
        const timer = setTimeout(() => {
          this.removeMarker(ping.id)
        }, timeUntilExpiry)
        this.expiryTimers.set(ping.id, timer)
      }
    }
  }

  removeMarker(pingId) {
    const marker = this.markers.get(pingId)
    if (marker) {
      marker.remove()
      this.markers.delete(pingId)
    }

    // Clear expiry timer if exists
    const timer = this.expiryTimers.get(pingId)
    if (timer) {
      clearTimeout(timer)
      this.expiryTimers.delete(pingId)
    }
  }

  disconnect() {
    // Unsubscribe from ActionCable
    if (this.subscription) {
      this.subscription.unsubscribe()
    }

    // Clear all expiry timers
    this.expiryTimers.forEach(timer => clearTimeout(timer))
    this.expiryTimers.clear()

    // Remove map
    if (this.map) {
      this.map.remove()
    }
  }
}
