# Installer
NSIS Installer script and resources for the Starsiege Players distribution

Ideally, we wouldn't use any external plugins; however, an ideal setup would strictly be a network-style installer. The current NSIS authoring package does not provide an up-to-date network downloader

## Goals
* Achieve an installation experience as close to the original Starsiege installer as possible
* Support upgrading existing installs
* Only download required files, based on user choices, from installer CDN

## Plugins used

* [NSCurl](https://github.com/negrutiu/nsis-nscurl)
* [Nsis7z](https://nsis.sourceforge.io/Nsis7z_plug-in)
