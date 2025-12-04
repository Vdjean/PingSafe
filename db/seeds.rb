
puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
Ping.destroy_all
UserReward.destroy_all
UserLevel.destroy_all
Reward.destroy_all
Level.destroy_all
User.destroy_all

puts "Creating levels..."
levels_data = [
  { points: 0 },
  { points: 100 },
  { points: 500 },
  { points: 1000 },
  { points: 2500 }
]

levels_data.each do |level_data|
  Level.create!(level_data)
end
puts "Created #{Level.count} levels"

puts "Creating rewards..."
rewards_data = [
  { reward_type: "first_ping" },
  { reward_type: "five_pings" },
  { reward_type: "badge_bronze" },
  { reward_type: "badge_silver" },
  { reward_type: "helpful_citizen" },
  { reward_type: "photo_master" }
]

rewards_data.each do |reward_data|
  Reward.create!(reward_data)
end
puts "Created #{Reward.count} rewards"

puts "Creating users..."
sara = User.create!(
  email: "sara@pingsafe.com",
  password: "sara123",
  first_name: "Sara",
  last_name: "Spadari",
  pseudo: "sara_d",
  phone: "0612345678",
  score: 450,
)

matteo = User.create!(
  email: "matteo@pingsafe.com",
  password: "matteo123",
  first_name: "Matteo",
  last_name: "Garbugli",
  pseudo: "matt_r",
  phone: "0623456789",
  score: 200
)

victor = User.create!(
  email: "victor@pingsafe.com",
  password: "victor123",
  first_name: "Victor",
  last_name: "Dejean",
  pseudo: "vic_dj",
  phone: "0634567890",
  score: 1200
)
puts "Created #{User.count} users"

puts "Assigning levels to users..."
UserLevel.create!(user: sara, level: Level.find_by(points: 100), level_name: "Level 2")
UserLevel.create!(user: matteo, level: Level.find_by(points: 100), level_name: "Level 2")
UserLevel.create!(user: victor, level: Level.find_by(points: 1000), level_name: "Level 4")
puts "Created #{UserLevel.count} user levels"

puts "Assigning rewards to users..."
UserReward.create!(user: sara, reward: Reward.find_by(reward_type: "first_ping"))
UserReward.create!(user: sara, reward: Reward.find_by(reward_type: "badge_bronze"))
UserReward.create!(user: matteo, reward: Reward.find_by(reward_type: "first_ping"))
UserReward.create!(user: victor, reward: Reward.find_by(reward_type: "first_ping"))
UserReward.create!(user: victor, reward: Reward.find_by(reward_type: "five_pings"))
UserReward.create!(user: victor, reward: Reward.find_by(reward_type: "photo_master"))
puts "Created #{UserReward.count} user rewards"

puts "Creating pings (pickpocket alerts)..."
ping1 = Ping.create!(
  user: sara,
  date: Date.today - 3,
  heure: Time.parse("14:30"),
  latitude: 48.8606,
  longitude: 2.3376,
  comment: "Pickpocket repere pres du Louvre, technique d'encerclement des touristes",
  photo: "ping_sara_pickpocket.jpg"
)

ping2 = Ping.create!(
  user: matteo,
  date: Date.today - 2,
  heure: Time.parse("09:15"),
  latitude: 48.8584,
  longitude: 2.2945,
  comment: "Vol a la tire en cours pres de la Tour Eiffel",
  photo: "ping_matteo_pickpocket.jpg"
)

ping3 = Ping.create!(
  user: victor,
  date: Date.today - 1,
  heure: Time.parse("18:45"),
  latitude: 48.8530,
  longitude: 2.3499,
  comment: "Pickpocket dans le metro ligne 1 station Chatelet, technique de la bousculade",
  photo: "ping_victor_pickpocket1.jpg"
)

ping4 = Ping.create!(
  user: victor,
  date: Date.today,
  heure: Time.parse("11:00"),
  latitude: 48.8867,
  longitude: 2.3431,
  comment: "Arnaque a la petition a Montmartre, technique d'encerclement",
  photo: "ping_victor_pickpocket2.jpg"
)
puts "Created #{Ping.count} pings"

puts ""
puts "=" * 50
puts "SEED COMPLETED!"
puts "=" * 50
puts ""
puts "Users credentials:"
puts "  - sara@pingsafe.com    / sara123    (pseudo: sara_d)"
puts "  - matteo@pingsafe.com  / matteo123  (pseudo: matt_r)"
puts "  - victor@pingsafe.com  / victor123  (pseudo: vic_dj)"
puts ""
puts "Summary:"
puts "  - #{User.count} users"
puts "  - #{Level.count} levels"
puts "  - #{Reward.count} rewards"
puts "  - #{Ping.count} pings (alertes pickpocket)"
