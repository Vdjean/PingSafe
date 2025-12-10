import { Controller } from "@hotwired/stimulus"
import { subscribeToPings } from "channels/pings_channel"

export default class extends Controller {
  static targets = [
    "container",
    "modal",
    "timerText",
    "modalPhoto",
    "photoImg",
    "photoPlaceholder",
    "tagsContainer",
    "tagPersons",
    "personsText",
    "tagSign",
    "signText",
    "modalComment",
    "commentText"
  ]
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

  // Lock screen orientation to portrait
  if (screen.orientation && screen.orientation.lock) {
    screen.orientation.lock('portrait').catch(err => {
      console.log('Orientation lock not supported:', err)
    })
  }

  mapboxgl.accessToken = this.accessTokenValue

  this.markers = new Map()
  this.expiryTimers = new Map()
  this.isTracking = false

  const defaultCenter = [2.3522, 48.8566]
  const defaultZoom = 13

  this.map = new mapboxgl.Map({
    container: this.containerTarget,
    style: "mapbox://styles/mapbox/streets-v12",
    center: defaultCenter,
    zoom: defaultZoom,
    attributionControl: true,
    // Enable rotation for compass mode
    boxZoom: true,
    doubleClickZoom: true,
    dragRotate: true,
    dragPan: true,
    keyboard: true,
    scrollZoom: true,
    touchZoomRotate: true,
    touchPitch: true,
    bearing: 0, // Initial north-facing
    pitch: 0 // Flat view initially
  })

  this.geolocateControl = new mapboxgl.GeolocateControl({
    positionOptions: {
      enableHighAccuracy: true
    },
    trackUserLocation: true,
    showUserHeading: true,
    showUserLocation: true,
    fitBoundsOptions: {
      maxZoom: 16
    }
  })

  this.map.addControl(this.geolocateControl, "top-right")

  // Function to start geolocation
  const startGeolocation = () => {
    setTimeout(() => {
      const geolocateButton = document.querySelector('.mapboxgl-ctrl-geolocate')
      if (geolocateButton && !geolocateButton.classList.contains('mapboxgl-ctrl-geolocate-active')) {
        geolocateButton.click()
        console.log('Geolocation and compass tracking started')
      }
    }, 800)
  }

  this.map.on("load", () => {
    this.addPingMarkers()
    this.subscribeToChannel()
    startGeolocation()
  })

  // If map is already loaded (when navigating back), start geolocation immediately
  if (this.map.loaded()) {
    this.addPingMarkers()
    this.subscribeToChannel()
    startGeolocation()
  }

  // Handle geolocation success - move map to follow user
  this.geolocateControl.on('geolocate', (e) => {
    console.log('User location found at:', e.coords.latitude, e.coords.longitude)
    this.isTracking = true

    // Center map on user location smoothly
    this.map.easeTo({
      center: [e.coords.longitude, e.coords.latitude],
      zoom: 16,
      duration: 1000,
      essential: true
    })
  })

  // Handle tracking state changes
  this.geolocateControl.on('trackuserlocationstart', () => {
    console.log('Tracking started - user dot should be visible')
    this.isTracking = true
  })

  this.geolocateControl.on('trackuserlocationend', () => {
    console.log('Tracking stopped')
    this.isTracking = false
  })

  // Handle geolocation errors
  this.geolocateControl.on('error', (error) => {
    console.log('Geolocation error:', error.message)
  })

  // Track device orientation for compass mode
  if (window.DeviceOrientationEvent) {
    // Request permission for iOS 13+
    if (typeof DeviceOrientationEvent.requestPermission === 'function') {
      DeviceOrientationEvent.requestPermission()
        .then(permissionState => {
          if (permissionState === 'granted') {
            this.setupCompassTracking()
          }
        })
        .catch(console.error)
    } else {
      // Non-iOS or older iOS
      this.setupCompassTracking()
    }
  }
}

  setupCompassTracking() {
    let lastHeading = null

    window.addEventListener('deviceorientation', (event) => {
      if (event.alpha !== null) {
        // event.alpha gives compass heading (0-360 degrees)
        // Webkit uses event.webkitCompassHeading for iOS
        let heading = event.webkitCompassHeading || (360 - event.alpha)

        // Smooth the heading to avoid jittery rotation
        if (lastHeading !== null) {
          const diff = Math.abs(heading - lastHeading)
          // Only update if heading changed by more than 2 degrees
          if (diff < 2 && diff > 0.5) {
            heading = lastHeading + (heading - lastHeading) * 0.3
          }
        }

        lastHeading = heading

        // Always rotate, regardless of tracking state
        this.map.rotateTo(heading, { duration: 300, easing: t => t })
      }
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
    if (this.markers.has(ping.id)) return

    const el = document.createElement("div")
    el.className = "ping-marker"
    el.style.width = "50px"
    el.style.height = "50px"
    el.style.backgroundImage = "url('/fox-pin-full.png')"
    el.style.backgroundSize = "contain"
    el.style.backgroundRepeat = "no-repeat"
    el.style.backgroundPosition = "center"
    el.style.cursor = "pointer"

    el.addEventListener("click", (e) => {
      e.stopPropagation()
      this.openModal(ping)
    })

    const marker = new mapboxgl.Marker(el)
      .setLngLat([parseFloat(ping.longitude), parseFloat(ping.latitude)])
      .addTo(this.map)

    this.markers.set(ping.id, marker)

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

    const timer = this.expiryTimers.get(pingId)
    if (timer) {
      clearTimeout(timer)
      this.expiryTimers.delete(pingId)
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }

    this.expiryTimers.forEach(timer => clearTimeout(timer))
    this.expiryTimers.clear()

    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }

    if (this.map) {
      this.map.remove()
    }
  }

  openModal(ping) {
    if (!this.hasModalTarget) return

    this.updateTimer(ping.created_at)
    this.timerInterval = setInterval(() => this.updateTimer(ping.created_at), 60000)

    if (ping.blurred_photo_url) {
      this.photoImgTarget.src = ping.blurred_photo_url
      this.photoImgTarget.style.display = "block"
      this.photoPlaceholderTarget.style.display = "none"
    } else {
      this.photoImgTarget.style.display = "none"
      this.photoPlaceholderTarget.style.display = "flex"
    }

    this.parseAndDisplayComment(ping.comment)

    this.modalTarget.classList.add("active")
  }

  closeModal() {
    if (!this.hasModalTarget) return

    this.modalTarget.classList.remove("active")

    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimer(createdAt) {
    const created = new Date(createdAt)
    const now = new Date()
    const diffMs = now - created
    const diffMins = Math.floor(diffMs / 60000)

    let text
    if (diffMins < 1) {
      text = "A l'instant"
    } else if (diffMins === 1) {
      text = "Il y a 1 min"
    } else if (diffMins < 60) {
      text = `Il y a ${diffMins} min`
    } else {
      const hours = Math.floor(diffMins / 60)
      text = hours === 1 ? "Il y a 1 heure" : `Il y a ${hours} heures`
    }

    this.timerTextTarget.textContent = text
  }

  parseAndDisplayComment(comment) {
    this.tagPersonsTarget.style.display = "none"
    this.tagSignTarget.style.display = "none"
    this.modalCommentTarget.style.display = "none"

    if (!comment) return

    const personsMatch = comment.match(/Number of persons:\s*(\d+)/i)
    const signMatch = comment.match(/Distinguishing sign:\s*([^\n]+)/i)

    const commentsMatches = comment.match(/Comments:\s*([^N\n][^\n]*)/gi)
    let pureComment = null
    if (commentsMatches) {
      for (let i = commentsMatches.length - 1; i >= 0; i--) {
        const match = commentsMatches[i].replace(/Comments:\s*/i, "").trim()
        if (match && !match.startsWith("Number") && !match.startsWith("Distinguishing")) {
          pureComment = match
          break
        }
      }
    }

    if (personsMatch && personsMatch[1]) {
      const num = parseInt(personsMatch[1])
      this.personsTextTarget.textContent = num > 1 ? `${num} individus` : `${num} individu`
      this.tagPersonsTarget.style.display = "inline-flex"
    }

    if (signMatch && signMatch[1]) {
      const sign = signMatch[1].trim()
      if (sign && !sign.startsWith("Comments:")) {
        this.signTextTarget.textContent = sign
        this.tagSignTarget.style.display = "inline-flex"
      }
    }

    if (pureComment) {
      pureComment = pureComment.replace(/^\.\s*/, "").trim()
      if (pureComment) {
        this.commentTextTarget.textContent = `"${pureComment}"`
        this.modalCommentTarget.style.display = "flex"
      }
    }

    if (!personsMatch && !signMatch && !pureComment) {
      let cleanComment = comment.replace(/^Comments:\s*/i, "").trim()
      if (cleanComment) {
        this.commentTextTarget.textContent = `"${cleanComment}"`
        this.modalCommentTarget.style.display = "flex"
      }
    }
  }
}
