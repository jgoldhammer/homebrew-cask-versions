cask 'java11-ea' do
  version '11-ea+23'
  sha256 '7bfbcdcfdf8522faef9e389f13ae3a483a9581a2839dd9f0da5f558b33be2e56'

  url "https://download.java.net/java/early_access/jdk11/23/BCL/jdk-#{version}_osx-x64_bin.dmg"
  name 'Java Standard Edition Development Kit 11'
  homepage 'http://jdk.java.net/11/'

  # auto_updates true: JDK does not auto-update
  pkg 'JDK 11.pkg'

  postflight do
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Home", '/Library/Java/Home'],
                   sudo: true
    system_command '/bin/mkdir',
                   args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Home/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk-#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
                   sudo: true
  end

  uninstall pkgutil:   [
                         "com.oracle.jdk-#{version.split('-')[0]}",
                       ],
            launchctl: [
                         'com.oracle.java.Helper-Tool',
                         'com.oracle.java.Java-Updater',
                       ],
            quit:      [
                         'com.oracle.java.Java-Updater',
                         'net.java.openjdk.cmd', # Java Control Panel
                       ],
            delete:    [
                         "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents",
                         '/Library/Java/Home',
                       ],
            rmdir:     "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk"

  zap trash: [
               '~/Library/Application Support/Java/',
               '~/Library/Application Support/Oracle/Java',
               '~/Library/Caches/com.oracle.java.Java-Updater',
               '~/Library/Caches/Oracle.MacJREInstaller',
               '~/Library/Caches/net.java.openjdk.cmd',
               '~/Library/Preferences/com.oracle.java.Java-Updater.plist',
               '~/Library/Preferences/com.oracle.javadeployment.plist',
             ]

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/index.html'
    <<~EOS
      This Cask makes minor modifications to the JRE to prevent issues with
      packaged applications, as discussed here:

        https://bugs.eclipse.org/bugs/show_bug.cgi?id=411361

      If your Java application still asks for JRE installation, you might need
      to reboot or logout/login.
    EOS
  end
end
