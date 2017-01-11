# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( *.png *.jpg *.css admin/change_limit.js
  bootstrap.js
  waypoints.min.js
  counterup.min.js
  move-top.js
  easing.js
  jquery-2.1.4.min.js
  admin/change_permission.js
  channels/admin_room.js
  channels/rooms.js
  distributors/change_limit.js 
  sender.js
  transactions.js 
  jzBox.js)
