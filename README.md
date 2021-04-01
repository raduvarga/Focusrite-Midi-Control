# Focusrite Midi Control

NEW APP DOWNLOAD LINK (Mac & WIndows): https://www.raduvarga.com/software/focusrite-midi-control

Old App Download Link (Mac OSX): https://github.com/vargaradu/Focusrite-Midi-Control/raw/master/Focusrite%20Midi%20Control.zip

Similar App for Universal Audio interfaces: https://github.com/vargaradu/UA-Midi-Control

On Chrome you might receive a "Focusrite Midi Control.zip is not commonly downloaded and may be dangerous" warning, you have to click "Keep" to continue the donwload.

## What is it?

It's an App that let's you Midi Map the volumes of your Focusrite interface. You must have the Focusrite Control software installed. However, you do NOT have to have it running. The FocusriteControlServer service must be running, but that is automatically started by the system and you do not have to worry about it.

This works just like the iOS Control App: You need to approve it from the "Focusrite Control" sofware first, so you can have the appropriate permissions.
The Midi Mapping procedure should be failry intuitive.

If you want to have a slight performance gain, I suggest running only the Midi Control during a performance (uses less RAM and CPU then the original one)

## Why did you do it?

Because:
1. Controlling volumes using a mouse sucks
2. To unify my DAW volume controls with the Focusrite direct monitoring ones
3. For some tracks, I want to control the DAW loop volume and Focusrite monitor volume at the same time (and having the same value) 

Alas, you can now have a central mixer for both your DAW and Focusrite on the same Midi Controller.

## This doesn't work with my Focusrite machine

I've specifically tailored this app to work with my device, which is a Scarlett 18i8 (2nd gen).
There are quite a few input/output options, but there might be things that will be missing from your device.
Create an issue with your specific problem, and I'll see what I can sort out.

## But this doesn't work on Windows..help?

I've only coded an app for OSX because it was faster to achieve, but the hard part of cracking the code behind the code is done, so if you're a developer check the code/examples/resources in this project to make your own app for Windows, Android, whatever.

## Ok, so how did you do it?

I reverse-engineered Focusrite's messaging protocols.
Used Wireshark to capture TCP packets: https://www.wireshark.org/
Had the brave idea to make a cross-platform app (Java, C++, ..), but quickly abandoned the idea for the lazier route, which was to learn Swift and XCode and get it done quick and easy. 

A breakdown of how it's done:
- I copied the model of the "Focusrite Control" and "iOS Control", they are actually both TCP clients connecting to the FocusriteControlServer
- The TCP communication process is roughly:
  - Connect, then send a "client-details" message with your name and key
  - Constantly (every ~3 secs) send a "keep-alive" message
  - BTW, every TCP message has a "Length=0009ab" suffix, with the length of your message as the nr. This is both used in how you read and write to the TCP socket.
  - You then will receive a detailed description of the connected devices
  - You then will have to subscribe to your device
  - On the Focusrite Control Software, you will approve the Focusrite Midi Control client
  - Then you should receive device/value updates which will be reflected in the UI
  - You will send value updates when you have the appropriate midi events comming in

## How to build

To build this project, you must open the ".xcworkspace" file in XCode and run it.

## Appendix

This is my first time I've written an OSX app, so don't judge the code too hard.
If you need help developing your own Focusrite client, feel free to contact me.
Happy Midi Mapping!

