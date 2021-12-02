# Installer
NSIS Installer script and resources for the Starsiege Players distribution

Ideally, we wouldn't use any external plugins; however, an ideal setup would strictly be a network-style installer. The current NSIS authoring package does not provide an up-to-date network downloader.

## Goals
* Achieve an installation experience as close to the original Starsiege installer as possible 
* TODO: Support upgrading existing installs
* TODO: Only download required files, based on user choices, from installer CDN

## Plugins Used

* [NSCurl](https://github.com/negrutiu/nsis-nscurl)
* [Nsis7z](https://nsis.sourceforge.io/Nsis7z_plug-in)

## Notes on Authoring and Releasing

 1. Simply clone the following repositories as siblings to the installer directory
      * [https://github.com/StarsiegePlayers/ss-rerelease](StarsiegePlayers/ss-rerelease)
      * [https://github.com/StarsiegePlayers/ss-rerelease-extras](StarsiegePlayers/ss-rerelease-extras)
      * [https://github.com/StarsiegePlayers/ss-rerelease-server](StarsiegePlayers/ss-rerelease-server)
 2. Make the necessary changes to those directory trees
 3. Ensure the changes are committed back to their respective git repo
 4. Compile it using either the GUI or the CLI NSIS compiler
      * For the GUI Compiler launch `nsisw.exe` and drag `setup.nsi` to the window or open it via the File menu.
      * For the CLI Compiler run `makensis.exe setup.nsi` in your favorite terminal emulator you can append `/PAUSE` to the command line if you wish to run it in a batch script
 5. Test the installer in VMs targeting Windows 7 up to Windows 11 (while we could test on Vista as well, it is fairly unreasonable to do so due to the overall lack of users on Vista)
 6. Release and Upload the Compiled Installer

## Notes on Network Installation

A large goal for the installer is to download the minimal set of changes for a given install if upgrading, or the selected options if adding feature / performing a fresh install. This is where the Nsis7z and NSCurl plugins come into play. Further research and experimentation are needed - specifically around downloading and parsing a manifest and displaying the sections where applicable. 

## Notes on NSIS Compression

If not creating a network-based installer, the standard file includes NSIS's built-in LZMA compression, which seems to work the best.
There are several if statements for `NSIS_7z_COMPRESSION` that only exist for testing at this point, the code remains for future reference.

## Notes on Images Used in the Installer

NSIS is more or less a direct extension of the win32 API, and as such, the native image format is Device Independent Bitmaps, or DIBs - in a Microsoft Bitmap v2 container.

While it may be beneficial in the future for the NSIS project to add an automatic conversion feature, such a feature doesn't exist currently.

Converting images such as PNGs over to BMPv2 can be accomplished by using [ImageMagick](https://imagemagick.org/script/download.php)

An example conversion would look like the following:

`magick convert image.png BMP2:image.bmp` 
