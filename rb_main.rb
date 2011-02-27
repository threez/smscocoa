#
# rb_main.rb
# SMSSend
#
# Created by Vincent Landgraf on 19.02.11.
# Copyright 2011 Vincent Landgraf. All rights reserved.
#

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
framework 'AddressBook'

main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation

# Loading all vendor gems
Dir.glob(File.join(dir_path, "gems", "*")).each do |path|
  puts "load lib: #{File.join(path, "lib")}"
  $:.unshift File.join(path, "lib")
end

# Loading all the Ruby project files.
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  if path != main
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
