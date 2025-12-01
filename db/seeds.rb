# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Création des niveaux
levels_data = [
  { points: 0 },      # Niveau débutant
  { points: 100 },    # Niveau 1
  { points: 250 },    # Niveau 2
  { points: 500 },    # Niveau 3
  { points: 1000 },   # Niveau 4
  { points: 2500 }    # Niveau expert
]

levels_data.each do |level_data|
  Level.find_or_create_by(points: level_data[:points])
end

puts "#{Level.count} niveaux créés"
