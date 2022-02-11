---
layout: post
title: Setup 3D objects thumbnailer in Xfce/Thunar.
categories:
- software
tags:
- 3d
- ubuntu
- xfce
- thunar
- thumbnail
- ux
---


* content
{:toc}

## Background

Recently I started to work a lot with 3D objects. Most of them are represented as [STL models](https://en.wikipedia.org/wiki/STL_(file_format)) and I found out that it's becoming very difficult to find model in a file manager if there is many.
Plenty of my colleagues use MacOS, and I've noticed that this OS has built-in preview for 3D models, like this:

![mac](/assets/images/3d-objects-thumbnailer-in-xfce/mac-preview.jpg)

I started to looking for available options on Linux. I use Xubuntu 20.04, so I need something for [Thunar](https://en.wikipedia.org/wiki/Thunar) since it's default file manager.
There are not so many options unfortunately, but I found [stl-thumb](https://github.com/unlimitedbacon/stl-thumb).
The installation is manual an requires several steps:
```
$ wget https://github.com/unlimitedbacon/stl-thumb/releases/download/v0.4.0/stl-thumb_0.4.0_amd64.deb
$ sudo apt install stl-thumb_0.4.0_amd64.deb
$ sudo apt install -f # in my case it also required installing some additional packages
```

As expected it doesn't work out of the box, so I started to lurk an internet to find a solution.
So, to make it's working I had to put such configs:
`/etc/xdg/tumbler/tumbler.rc`
```
[STL-Thumbnailer]
Disabled=false
Priority=1
Locations=
MaxFileSize=2147483648
```
And
`/usr/share/thumbnailers/stl-thumb.thumbnailer`
```
[Thumbnailer Entry]
TryExec=stl-thumb
Type=STL-Thumbnailer
Exec=stl-thumb -f png -s %s %i %o
MimeType=model/stl;model/x.stl-ascii;model/x.stl-binary;application/sla;
```

And that's it!

Now I can see the nice renders in my file manager:
![screen](/assets/images/3d-objects-thumbnailer-in-xfce/rendered-stl.png)

Hope it could help someone.
