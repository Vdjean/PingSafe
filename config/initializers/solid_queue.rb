# Configure Solid Queue to use the primary database
# instead of a separate queue database
Rails.application.config.after_initialize do
  SolidQueue::Record.connects_to database: { writing: :primary, reading: :primary }
end
