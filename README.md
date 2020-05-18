  
<img src="https://github.com/farique1/e-spelho/blob/master/Images/GitHub_e-spelho.png" alt="e-spelho" width="300" height="80">  
  
# e-spelho   
  
## What it is  
**e-spelho** (*espelho* means mirror in Portuguese) is a proof of concept/prototype **smart mirror** system.  
Developed in **Autoit** it needs a full Windows installation to run making it less than ideal for a bathroom situation not only regarding to space allocation but also in maintenance and energy consumption.  
  
My hardware implementation was done using an old notebook monitor, an excellent Toshiba Satellite 5100 super glossy 15" screen at 1600x1200 resolution that was as impressive as the first retina monitors at the time (as a matter of fact, the whole project began as a way to put this panel to good use again), with a generic chinese controller powered by an old Windows XP rig.  
  
>Please be advised **the published code is by no means functional** "out of the box". It's been years since I last run it and I don't have access to a Windows box to test. I blindly edited it (to translate some things, add minimal comments and remove the several API keys) and  the whole system worked as a hodgepodge of auxiliary tools outside of the code itself.  
It is posted as an inspiration and/or foundation from where to build upon. It has some very good ideas (even if not very good implemantation) and the coding is somewhat there to steal from.  
  
>I won't discuss the hardware here.  
  
![Versions](https://github.com/farique1/e-spelho/blob/master/Images/GitHub_Versions.jpg)  
Last mockup, early prototype and "finished" product.  
  
![Prototypes](https://github.com/farique1/e-spelho/blob/master/Images/GitHub_Prototype.jpg)  
GUI test: main screen, cartoons and traffic map.  
  
<img src="https://github.com/farique1/e-spelho/blob/master/Images/GitHub_Youtube.jpg" alt="Youtube Video" width="400" height="225">  

[In aciotn (not a lot)](https://youtu.be/ovK2uJhMNeM)  
  
## The system  
  
The system is composed of a main **Autoit** script running several modules at different time intervals (I am calling them modules but they are actually just functions). Each module has its own characteristics and get its information from several different sources on several different ways. Most of them uses plain text files (several examples included for convenience) to store information and communicate with their support mechanisms. Among the tools used to gather and parse information where several site APIs, a very simple web server, IFTTT, RSSs, a mobile app and the such.  
  
Below I'll try to describe each module based on what I remember and could infer based on a quick review of the system (I didn't thoroughly reviewed the code so I can be wrong on occasion).  
  
- **Clock calendar.**  
  
Nothing to see here, just a natural language calendar and regular digital clock with seconds.  
  
- **Commute-Traffic / Events**  
  
Here things begin to get interesting. Below the clock is a module showing the time it would take to get to work if I left now. The script would call the the Google Maps API every 30 minutes from 7 to 11 in the morning to gather the data (I had to set a two point route and add their time so I could replicate the path I actually took).  
Also shown were the day and hour of the last trip on the same week day and the average duration (with the sample amount) of every previous same week day. This was fed by a mobile app made on Unity (overkill but the only mobile programming tool I knew how to use, the upside is it became really a beauty, mimicking the mirror layout with animations. Sadly I LOST THE UNITY PROJECT and only have the compiled Xcode) and used on a old iPhone 4. Every day I would record the time I left home and the time I arrived at work, just two taps, normally. It had the option to tag if there were any unexpected delays like a different route, a crash, a long stop or weird weather. The log would go to an internal database and I could push all of them to the server when I got a connection (usually as soon as a got to the office.) The **Autoit** script downloaded them from the server.  
  
The traffic and commute would only appear on week days until noon. On any other time an event viewer replaced it.  
  
The event viewer gathered information about events I confirmed on Facebook (using its API) and would cycle the events, showing name, place, time, day (with day name and how many days from now) and the total number of events. I also wanted to be able to manually enter events but I think I never implemented that.  
  
- **The cleaning lady schedule and payment**  
  
I always forgot to have cash available to pay the cleaning lady so this module showed a timeline with the days of the month she would come. It would highlight the days I was supposed to pay her and warn me with text messages when it was coming. I still missed the payments.  
This was all hard coded into the script.  
  
- **News**  
  
The news viewer showed the title of the five most relevant science news on ScienceDaily.com (through their RSS feed, straight from the script) and cycled through them, highlighting each one and showing a preview underneath. Besides the preview, there was a QR Code (generated on the fly) that linked to the news URL so I could scan and save it on my phone to read later if I was interested. The news were refreshed every hour or so, I think.  
  
- **Calendar**  
  
Below the news was the calendar. Nothing super fancy here, it just showed the events of the day and their time. All-Day events, like birthdays, were shown at the top. If there were more information than could fit on the screen a "..." was shown and the appointments would cycle (almost sure I implemented that.)  
I think I had an IFTTT rule to collect the appointments of the day and save a text version of them on the server for the script to download.  
  
- **Weather**  
  
The weather was a pretty complete module, refreshed every hour, it showed the current temperature (alternating between real and perceived) and condition, the moon phase, wind speed, visibility, humidity, cloud cover, rain chance, rain amount, and sunset and sundown times (depending on the time of the day).  
It also showed the prediction for three and six hours in the future with condition, temperature and rain chance.  
At last there were previsions for the next five days with conditions, maximal and minimal temperature and moon phase.  
These were gathered from the Dark Sky API (previously Forecast io) and parsed on the script itself.  
  
- **Lend list**  
  
As with the cleaning lady payment, I also almost always forget when I lend something to someone (this is not the last of the memory helpers) and I end up losing the thing forever (my friends will never, of their own volition, return an item) so I made a list I could see every day with the things I lent, to whom, the day I lent the thing and how many days have elapsed since. No more "stealing" (are you reading, BOB!?)  
This was fed via a web page, it would ask for the person, the thing and the day and a PHP script would save the information as a txt file on the server to be fetched by the script to the **e-spelho** local folder. On the same web page I could also see a list and delete an item on the rare occasion someone actually returned something.  
  
- **Greetings and messenger**  
  
At last, at the bottom of the mirror was a module that showed a random greeting, pieced together from pre made Title, Greetings and Compliments lists and a messenger module that anyone could use to send a short message that would be displayed there, with the sender name, on the appointed day. If there were more than one message they would cycle and the total and current number was shown below. I did this so I would not forget to take important things to work in the morning but as this was open to the public you can imagine it degenerated quickly!  
This was also accomplished through a public web page and a PHP script.  
  
<img src="https://github.com/farique1/e-spelho/blob/master/Images/GitHub_SupportSite.png" alt="Support Site" width="1037" height="349">  
  
- **Cartoon display**  
  
By pressing the mouse button (this would later be implemented as a touch action on the mirror frame) the whole GUI would be replaced with a screen with the latest XKCD and SMBC cartoons. There was an algorithm to better fit them together the on screen according to their dimensions. They both have simple APIs and RSSs to fetch the cartoons, it was done on the code itself.  
  
- **Traffic map**  
  
Pressing the mouse button again brought a google maps showing the traffic intensity on the region, great for planning the departure time when not going to work.  
  
A third press on the mouse lead back to the main GUI.  
  
- **Auto sleep**  
  
Later I added a option to turn off the monitor if there were nobody there. This was simple enough, a webcam with a motion detection saved a single image on a folder when someone was present. The script monitored this folder and if there was something there it would turn on the screen and delete the image. After about 15 minutes (I think) it would check the folder again and turn off the screen if there was nothing there.  
Amazingly it took me a few days to realize having a webcam on my bathroom was not a good idea! I fixed that by covering the lens with an opaque plastic, folding it just the amount needed to detect motion without really showing anything.  
Anyway, I regretted this as after that (could've been a coincidence) the screen started to deteriorate, maybe due to internal condensation caused by not enough warmth.  
  
<img src="https://github.com/farique1/e-spelho/blob/master/Images/GitHub_ScreenRot.jpg" alt="Screen rot" width="320" height="399">  
  
## Conclusion  
  
And that is it, the code is crude and flaky, has some bugs (I remember it always crashed after running for several continuous days, probably due to an overflow on the clock variable) and no error catching, it would stop working if you shouted ai it.  
I hope, however, it works as an inspiration and motivation to someone wishing to do something similar.  
My plan was to port it to something running on a browser, local or on a server, on a Raspberry Pi.  
Maybe someday.  
If you do it (use Python, use Python!), let me know.  
  
Cheers.  
