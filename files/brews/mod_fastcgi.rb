require 'formula'

class ModFastcgi < Formula
  url 'https://fossies.org/linux/www/apache_httpd_modules/mod_fastcgi-2.4.7-0910052141.tar.gz'
  homepage 'http://www.fastcgi.com/'
  sha256 'b0c8cfafcd403f109738da9c62d08c0c67d023521bf0bb5a465ece40b111726d'
  version '2.4.7-boxen1'

  mirror 'https://fossies.org/linux/www/apache_httpd_modules/mod_fastcgi-2.4.7-0910052141.tar.gz'

  option "with-brewed-httpd22", "Use Homebrew's Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew's Apache httpd 2.4"
  option "with-osx-httpd24", "Use OS X 10.10 Apache httpd 2.4"

  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"

  def apache_apxs
    if build.with? "brewed-httpd22"
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? "brewed-httpd24"
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      "/usr/sbin/apxs"
    end
  end

  def apache_configdir
    if build.with? "brewed-httpd22"
      "#{etc}/apache2/2.2"
    elsif build.with? "brewed-httpd24"
      "#{etc}/apache2/2.4"
    else
      "/etc/apache2"
    end
  end

  def patches
    if (build.with? "brewed-httpd24") || (build.with? "osx-httpd24")
      'https://raw.githubusercontent.com/ByteInternet/libapache-mod-fastcgi/byte/debian/patches/byte-compile-against-apache24.diff'
    end
  end

  def install
    system "#{apache_apxs} -o mod_fastcgi.so -c *.c"
    libexec.install ".libs/mod_fastcgi.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to contain:
      LoadModule fastcgi_module #{libexec}/mod_fastcgi.so

    Upon restarting Apache, you should see the following message in the error log:
      [notice] FastCGI: process manager initialized

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
