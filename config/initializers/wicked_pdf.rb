# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

require 'rbconfig'

if RbConfig::CONFIG['host_os'] =~ /linux/
  arch = RbConfig::CONFIG['host_cpu'] == 'x86_64' ? 'wkhtmltopdf_linux_x64' : 'wkhtmltopdf_linux_386'
elsif RbConfig::CONFIG['host_os'] =~ /darwin/
  arch = 'wkhtmltopdf_darwin_386'
else
  raise "Invalid platform. Must be running Intel-based Linux or OSX."
end

WickedPdf.config = {
  exe_path: "#{ENV['GEM_HOME']}/gems/wkhtmltopdf-binary-#{Gem.loaded_specs['wkhtmltopdf-binary'].version}/bin/#{arch}"
}




#WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  #exe_path: '/usr/local/bin/wkhtmltopdf'
  #   or
#  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # layout: 'pdf.html',
#}

