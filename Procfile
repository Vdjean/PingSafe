web: bin/rails server -p ${PORT:-3000} -e $RAILS_ENV
worker: bin/rails solid_queue:start
release: bin/rails db:migrate
