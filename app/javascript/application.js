// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

// Fix for iOS viewport height and edge-to-edge display
const setVH = () => {
  const vh = window.innerHeight * 0.01;
  document.documentElement.style.setProperty('--vh', `${vh}px`);

  // Also set safe area insets as custom properties for easier use
  document.documentElement.style.setProperty('--safe-top',
    getComputedStyle(document.documentElement).getPropertyValue('env(safe-area-inset-top)') || '0px');
  document.documentElement.style.setProperty('--safe-bottom',
    getComputedStyle(document.documentElement).getPropertyValue('env(safe-area-inset-bottom)') || '0px');
}

// Set on load
setVH();

// Update on resize and orientation change
window.addEventListener('resize', setVH);
window.addEventListener('orientationchange', setVH);

// Check if running as PWA
const isPWA = window.matchMedia('(display-mode: standalone)').matches ||
              window.navigator.standalone === true;

if (isPWA) {
  document.documentElement.classList.add('is-pwa');
  console.log('Running as PWA - Edge-to-edge enabled');
}
