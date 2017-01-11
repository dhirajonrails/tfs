// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui.min.js
//= require jquery_ujs
//= require underscore.js
//= require jquery.validate.min.js
//= require jquery.maskedinput.min.js
//= require ace.min.js
//= require moment.min.js
//= require jquery.marquee.min.js
//= require ace-elements.min.js
//= require bootstrap.min.js
//= require jquery.sparkline.min.js
//= require jquery-ui.custom.min.js
//= require ace-extra.min.js
//= require validation.js
//= require infinite_scroll
//= require common

$(document).ready(function(){
  $('.marquee').marquee({
    pauseOnHover: true,
    speed: 15000
  });
  })
