desc "install dependencies"
task :install do
  ENV["BUNDLE_PATH"] = "vendor"
  sh "bundle install"
end

desc "build the applicatio release"
task :release do
  sh "xcodebuild -project SMSSend.xcodeproj/ -configuration Release"
end
