# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

def flutter_install_plugin_pods(application_path = nil, relative_symlink_dir, platform)
  # defined_in_file is set by CocoaPods and is a Pathname to the Podfile.
  application_path ||= File.dirname(defined_in_file.realpath) if self.respond_to?(:defined_in_file)
  raise 'Could not find application path' unless application_path

  # Prepare symlinks folder. We use symlinks to avoid having Podfile.lock
  # referring to absolute paths on developers' machines.

  symlink_dir = File.expand_path(relative_symlink_dir, application_path)
  system('rm', '-rf', symlink_dir) # Avoid the complication of dependencies like FileUtils.

  symlink_plugins_dir = File.expand_path('plugins', symlink_dir)
  system('mkdir', '-p', symlink_plugins_dir)

  plugins_file = File.join(application_path, '..', '.flutter-plugins-dependencies')
  plugin_pods = flutter_parse_plugins_file(plugins_file, platform)
  plugin_pods.each do |plugin_hash|
    plugin_name = plugin_hash['name']
    plugin_path = plugin_hash['path']
    if (plugin_name && plugin_path)
      symlink = File.join(symlink_plugins_dir, plugin_name)
      File.symlink(plugin_path, symlink)

      if plugin_name == 'flutter_ffmpeg'
        pod 'flutter_ffmpeg/min-gpl-lts', :path => File.join(relative_symlink_dir, 'plugins', plugin_name, platform)
      else
        pod plugin_name, :path => File.join(relative_symlink_dir, 'plugins', plugin_name, platform)
      end
    end
  end
end

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
