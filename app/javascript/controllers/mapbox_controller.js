import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    accessToken: String,
    pings: Array
  }

  connect() {
    if (typeof mapboxgl === "undefined") {
      console.error("Mapbox GL JS not loaded")
      return
    }

    mapboxgl.accessToken = this.accessTokenValue

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
    })
  }

  addPingMarkers() {
    if (!this.hasPingsValue || this.pingsValue.length === 0) return

    this.pingsValue.forEach(ping => {
      // Create custom marker element
      const el = document.createElement("div")
      el.className = "ping-marker"
      el.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#e63946" stroke="#fff" stroke-width="2">
          <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
          <circle cx="12" cy="10" r="3" fill="#fff"/>
        </svg>
      `

      // Create popup
      const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(`
        <div class="ping-popup">
          <strong>${ping.comment || "Signalement"}</strong>
          <br>
          <small>${ping.date || ""}</small>
        </div>
      `)

      // Add marker to map
      new mapboxgl.Marker(el)
        .setLngLat([parseFloat(ping.longitude), parseFloat(ping.latitude)])
        .setPopup(popup)
        .addTo(this.map)
    })
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
