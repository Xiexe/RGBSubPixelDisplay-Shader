# RGBSubPixelDisplay-Shader
A physically accurate screen shader, that displays the screen as subpixels. 

Set the tiling of the texture to whatever the resolution of your screen is divided by two. 

My texture contains 6 subpixels, two of each color, so you would have two whole pixels. 


Any pixel texture marked as 2px will need to be set to your resolution / 2.
A 4K resolution of 3840 x 2160 with this specific texture would be a tiling of 1920 x 1080.

A texture with 1px can be set to proper resolution without / 2. 


![Gif](https://thumbs.gfycat.com/FriendlyFelineEyra-size_restricted.gif)
![Gif2](https://thumbs.gfycat.com/AnxiousCookedGoat-size_restricted.gif)
