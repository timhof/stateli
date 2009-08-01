# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_stateli_session',
  :secret      => '5ba44dc7077686a7a8eb1572c4182b19f9e49e6b1f14e6f2e15b8a73f2bd8a0627bb43cb923f14aed6d7e45b50e0747fa92f79c611b63a3a38359bad38b2833c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
