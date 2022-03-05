# notifydb
Rust based dbus notification store with a Rust/Flutter GUI frontend.

![](https://i.imgur.com/DAvkT9k.png)

### Work in progress! 

---
### Notes:
#### While the majority of the functionality is there and working, there are a few hardcoded paths, I believe that I need to fix up and things of that nature., so may or may not work out of the box just yet. 

The notification listeners ability to run as a tray icon is something I just implemented to test out.  
Not sure if I want to keep it that way, as gtk-rs has its own event loop that doesn't quite play great with the main loop used to listen for notifications and for some reason causes them to be inserted twice fairly often. Looking into that still.   
I will either fix it, or just have the listener run as a service.
---
### Motivation:

There are two main reasons I made this. 

1. I wanted to learn Rust (be warned, this is the first thing I have made using Rust, so it is what it is)
2. I was tired of Pop_OS not showing the entire notification message in the notification center, and having no way of viewing the entire message. 
 (The frontend being Flutter was more an afterthought. Once I started making a simple one, I just wanted it to be nicer, so I did that)

Typical Scenario that happened far too often:   
    Backup failed notification! -> Shoot, better check which one... oh, the notification in the dropdown is cut off just before the server and path name, let me just click on it to view it..... and it's gone, forever.

---

Frontend Features:

- Filter by sending application
- Search by title or message body
- Automatic refresh of new incoming notifications
- Set overall max notifications to display
- Set max notifications to display per page
- Other stuff, probably. I can't remember.





---
![alt text](https://i.imgur.com/cg5ow2M.png "instance.id")