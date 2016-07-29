# AutoCmdLine Plugin (x86) - A Plugin For x64dbg

![](https://github.com/mrfearless/AutoCmdLine-Plugin-x86/blob/master/images/AutoCmdLine.png) [Current version: 1.0.0.3 - Last updated: 26/06/2016](https://github.com/mrfearless/AutoCmdLine-x86/releases/latest) For the x64 version of this plugin, visit [here](https://github.com/mrfearless/AutoCmdLine-Plugin-x64)

## Overview

A plugin to remember the command line and load it up automatically

## Features

* Add and/or change command line
* Remember command line
* Automatically set command line  

## How to install

* If x32dbg (x64dbg 32bit) is currently running, stop and exit.
* Copy the `AutoCmdLine.dp32` to your `x64dbg\x32\plugins` folder.
* Start x32dbg

## Notes

AutoCmdLine takes the modulename, the full filepath of the program that is loaded and being debugged and creates an MD5 hash from this value.
It searches in the plugins\AutoCmdLine.ini file for a matching profile section name and loads up the saved command line if it was set to 'remember' it.

'remember' perhaps should be named auto-load as it will auto load this command line the next time the same module is being debugged.

Arguments on the command line should be wrapped with double quotes "" and you should specify the fullpath for any arguments that require it.

This is to ensure compatability with windows and how it handles arguments and also with the way x64dbg sets the cmdline. 

## Information

* Written by [fearless](https://github.com/mrfearless)  - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x86 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x86-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* Some plugins make use of the MASM32 SDK found [here](http://www.masm32.com/masmdl.htm)

## x64dbg
* [x64dbg website](http://x64dbg.com)
* [x64dbg github](https://github.com/x64dbg/x64dbg)
* [x64dbg gitter](https://gitter.im/x64dbg/x64dbg)