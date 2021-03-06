require 'formula'

class Pillow < Formula
  homepage 'https://github.com/python-imaging/Pillow'
  url 'http://pypi.python.org/packages/source/P/Pillow/Pillow-2.0.0.zip'
  sha1 'b8e0e3a88d822f039a5cdd848abae98c1e74a295'
  head 'https://github.com/python-imaging/Pillow.git'

  conflicts_with 'pil',
    :because => 'both install the same "PIL" module but Pillow is the better maintained distribution for PIL.'

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'little-cms'
  depends_on 'graphicsmagick'
  depends_on 'freetype'
  depends_on 'jpeg'
  depends_on 'libtiff'

  def install
    # Help pillow find zlib and little-cms (Note freetype2 is detected correctly)
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula.factory('littlecms').opt_prefix}/lib', '#{Formula.factory('littlecms').opt_prefix}/include')"
      s.gsub! "JPEG_ROOT = None", "JPEG_ROOT = ('#{Formula.factory('jpeg').opt_prefix}/lib', '#{Formula.factory('jpeg').opt_prefix}/include')"
      s.gsub! "TIFF_ROOT = None", "TIFF_ROOT = ('#{Formula.factory('libtiff').opt_prefix}/lib', '#{Formula.factory('libtiff').opt_prefix}/include')"
      s.gsub! "FREETYPE_ROOT = None", "FREETYPE_ROOT = ('#{Formula.factory('freetype').opt_prefix}/lib', '#{Formula.factory('freetype').opt_prefix}/include')"
    end

    python do
      system python.binary, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt", "--single-version-externally-managed"
      # For python3 we append -py3 to the executable scripts:
      if python3
        [ "pilconvert", "pildriver", "pilfile", "pilfont", "pilprint" ].each do |f|
          bin.install "build/scripts-#{python.version.major}.#{python.version.minor}/#{f}.py" => "#{f}-py3.py"
        end
      end
    end

  end

  def test
    python do
      # Only a small test until https://github.com/python-imaging/Pillow/issues/17
      system "python", "-c", "import PIL; PIL.test()"
    end
  end
end
