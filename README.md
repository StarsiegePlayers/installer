# Installer
NSIS Installer script and resources for the Starsiege Players distribution

Ideally, we wouldn't use any external plugins; however, an ideal setup would strictly be a network-style installer. The current NSIS authoring package does not provide an up-to-date network downloader.

## Goals
* Achieve an installation experience as close to the original Starsiege installer as possible
* Support upgrading existing installs
* Only download required files, based on user choices, from installer CDN

## Plugins used

* [NSCurl](https://github.com/negrutiu/nsis-nscurl)
* [Nsis7z](https://nsis.sourceforge.io/Nsis7z_plug-in)

## Notes on Images

NSIS is more or less a direct extension of the win32 API, and as such, the native image format is Device Independent Bitmaps, or DIBs - in a Microsoft Bitmap v2 container.

While it may be beneficial in the future for the NSIS project to add an automatic conversion feature, such a feature doesn't exist currently.

Converting images such as PNGs over to BMPv2 can be accomplished by using [ImageMagick](https://imagemagick.org/script/download.php)

An example conversion would look like the following:

`magick convert image.png BMP2:image.bmp` 
