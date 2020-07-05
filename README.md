<img src="/Images/GitHub_e-spelho.png" alt="e-spelho" width="300" height="80">  
  
# e-spelho  
  
## What is it  
**e-spelho** (*espelho* means mirror in Portuguese) is a smart mirror "engine" module tasked with delivering timed, organized, standardized information to an external application, most likely a graphical front end.  
The engine format came as an answer to the limitation of the [prototype](Autoit%20version) that, being an Autoit script, was limited to run on a full Windows installation and nothing else.  
Having a Python module worry about the collection, formatting and timely delivery of the data makes the integration on a variety of platforms and environments only a question of implementing a front-end, be it on Windows, Mac, Linux, Raspberry or even on mobile or a browse through a web server.  
  
>Below is the prototype implementation and hardware, some modules shown are not implemented on the final engine.  
  
<img src="Autoit version/Images/GitHub_Youtube.jpg" alt="Youtube Video" width="400" height="225">  
  
[In aciotn (not a lot)](https://youtu.be/ovK2uJhMNeM)  
  
>The **e-spelho** and its front-end examples are in Portuguese but are easily localised to any language.  
  
## Setup  
  
The engine is a Python module imported on a main application, it works trough a series of modules (classes) and a timer (method). The `timer` calls each module on customisable intervals, the modules then gather the information needed, format them into standardised data lists and send them to the main program through function calls. The the custom output data lists further helps the implementation of the front-end making it easier to change data sources if needed without changing the read format  
  
The information is collected from a variety of sources, including several APIs and custom Google Sheets. These APIs are not provided and must be created and/or acquired beforehand, the code implementation makes them easy to integrate and each requirement is explained below on its own module breakup.  
  
A description of the exported data list for each module can be found in the [output data description page](DataOutput.md). The first item in each list is always a status number with `0` meaning all is ok and `1` meaning a problem, more codes are planned but not implemented yet. Subsequent items on the list are explained in the data description page and some have a variable length according to the availability of the data.  
Here is the *Clock* module data output list example:  
```  
[0] Status - integer  
[1] Epoch time - float  
[2] Current time - datetime  
[3] Hour 24h 0 padded - string  
[4] Minutes 0 padded - string  
[5] Seconds 0 padded - string  
[6] Hour 12h 0 padded - string  
[7] AM PM depends on local - string  
```  
  
Once the needed the API keys and data sources are set up and implemented into the code, it is ready to go.  
  
The `e-spelho` module should me imported on a front-end script. The `Espelho` class should be instanced with local functions or methods passed as arguments, associating them to **e-spelho** modules as needed. These functions will be called according to the **e-spelho** `timer` interval with the appropriated data list as argument.  
```Python  
import e_spelho as es  
mirror = es.Espelho(  
    ui_clock=local_clock,  
    ui_date=local_date,  
    ui_greetings=local_greetings,  
    ui_weather=local_weather,  
    ui_news=local_news,  
    ui_calendar=local_calendar,  
    ui_lending=local_lending,  
    ui_events=local_events,  
    ui_message=local_message  
)  
```  
>Note the missing *Comics* module. Its is not needed in this example.  
  
The modules can then be initialised with:  
```Python  
mirror.initialize()  
```  
This will instantiate all the needed classes, prepare the environment, fetch the initial information and call the local functions once with each module data list.  
  
Then it is just a matter of calling the **e-spelho** `timer` method on a regular basis. A local timer can be established to further granulate the display of information provided like paging through news, events, calendar and so on.  
```Python  
while True:  
    mirror.timer()  
```  
  
## Timer  
  
Internally the modules are called through the `timer` method on the `Espelho` class, they can be called at the start of every second, minute, hour or day. They can also be called at specific moments, from 7h to 11h or only at day 30 for instance. Changing their timing is just a question of moving their position on the method.  
> Remember that the modules uses API calls to get most of the information and that they are usually only needed on a daily basis, so plan they timing wisely to preserve API calls quote.  
  
## Modules  
  
Below are descriptions of each module and its requirement.  
For a full description of each module output see the [data lists](DataOutput.md).  
  
- **Clock**  
  
Nothing to see here, just the time, provided in several formats.  
Because of its simplicity this could also be implemented on the main application itself.  
This class is called every second by default but can be called every minute if a seconds display is not needed.  
  
- **Date**  
  
This module sends the date including several natural language day names.  
The language can be configured on the **e-spelho** code.  
This is called each day and can also be easily implemented on the main application.  
  
- **Greetings**  
  
The **e-spelho** can send randomised greetings containing a *greeting* (hi, hello, ...), a *title* (your name, a nickname, an adjective, ...) and a *short phrase* (How are you, ...) ramdomised from the `/Modules/Greetings/Greetings.txt` text file.  
The file must have one item each line starting with the *greetings* then a line with a single dash (`-`) the *titles*, another dash, the *phrases* and finally a last dash.  
This can be used to construct nice random messages like `Hi, John. Have a nice day.`  
This is called each day by default.  
  
- **Weather**  
  
The geographic location is obtained at https://ipinfo.io and the weather information comes from https://openweathermap.org through the One Call API. You must have a valid API key for the weather (free).  
The **e-spelho** gets the current weather and can get hourly forecast up to 48 hours on defined increments and daily forecast for the next 7 days (minute by minute forecast are ignored). The default is 2 hourly forecast 3 hours apart and forecast for the next 5 days.  
Icons for all the items are available on the module subfolder at `/Modules/Weather/Icons/` as 1024 pixels PNGs.  
The weather language and units can be configured on the **e-spelho** code.  
A copy of the most recent API response is saved as a file in case further API calls are not available. The data list contains the amount of time in seconds elapsed since the last successful call, this is useful to judge how to deal with old weather information if there is a prolonged connectivity problem.  
This module is called every hour by default.  
  
- **News**  
  
The news are fetched from https://newsapi.org and you must get a vali API key from there (free).  
You can configure the *amount*, *country* and *category* of the news and a QR code can be automatically generated (at http://goqr.me) with a link to the actual news page. The QR code image is downloaded to the News module subfolder (`/Modules/News/`) with the name `News_<news number>.png`. The QR code is useful as a way to navigate to the actual news without having to type the URL.  
A copy of the most recent API response is saved as a file and is used if further API calls are not available.  
This is called every day by default.  
  
  - **Cartoons**  
  
An image from the most recent **xkcd** and **SMBC** web cartoons can be downloaded and a link to the file and their dimensions are provided. They are downloaded to the Comics subfolder at `/Modules/Comics/`. The dimensions are useful if you want to implement an algorithm to optimally display both on the same screen.  
Other comics can be implemented on this module with relative ease.  
Copies of the most recent responses are saved as files along with the images in case further calls are not successful.  
This is called every day by default.  
  
- **Calendar**  
  
>This module require a Google API project and credentials file to generate the access token for the account.  
>Once you have that cleared up just put the `credentials.json` file on the **e-spelho** root folder.  
  
The calendar information comes from the current day appointments (events) of the Google Calendar associated account.  
The events can be gathered for the whole day or just from the current time on in case you are fetching more than once per day.  
The data list size varies according to the days appointments. If there is no appointments for the day the second item on the data list is `None`.  
This is called every day by default.  
  
- **Lend, Events and Messages**  
  
>These modules require a Google API project and credentials file to generate the access token for the account.  
>Once you have that cleared up just put the `credentials.json` file on the **e-spelho** root folder.  
  
Their information comes from a Google Sheet with each module information on its own sheet (tab) ideally fed by a Google Form (see [Collecting Info](#collect-info) below for more on this). You will need the spreadsheet ID and the sheet (tab) name and ID. The IDs can be found on the spreadsheet URL:  
```  
https://docs.google.com/spreadsheets/d/<spreadsheet ID>/edit#gid=<sheet ID>`  
```  
The modules information must be in the correct columns.  
  
The data list size varies according to the availability of the information. If there is nothing to display the second item on the data list is `None`.  
  
**Lending**  
The lending list is a list of items you lent, the person you lent to and the date so you never forget who has what for how long :)  
The sheet should be:  
| |A|B|C|D|  
|-|--|--|--|--|  
|1|Title|Title|Title|Title|  
|2|Entry date|Item|To whom|Date lent|  
|3|...|...|...|...|  
  
**Events**  
The Events list is a list to remind you of future events you intend to attend.  
The sheet should be:  
| |A|B|C|D|E|  
|-|--|--|--|--|--|  
|1|Title|Title|Title|Title|Title|  
|2|Entry date|Event|Description|Place|Date and time|  
|3|...|...|...|...|...|  
  
**Message**  
Anyone can send a message to be show at the indicated date. A Google Form linked to the spreadsheet with the information fields needed can be shared with friends. The Form can even be on a Google Sites for better presentation.  
The sheet should be:  
||A|B|C|D|  
|-|--|--|--|--|  
|1|Title|Title|Title|Title|Title|  
|2|Entry date|Message|From whom|Date to display|  
|3|...|...|...|...|...|  
  
>The date format from the Forms depends on the associated Google Account settings and should be matched on the **e-spelho** code. The **`A`** column is the date of the entry and is automatically generated by the Google Form, it is not used except by the Message module.  
  
**Get Sheets Data**  
All the data for the Lending, Events and Message modules are fetched in one API call to optimise the access. There is a class to do that and it should be called before any of the three associated classes.  
  
**Delete Events and Messages**  
The Lending list entries must be deleted manually according to the return of the goods.  
The Message and Events however are not needed after their due dates so there is a class that is called every month at day 1 (can be changed) to automatically delete the past messages and events from the associated Google Sheet.  
  
<a id="collect-info"></a>**Collecting the information for the modules**  
The Lending, Events and Message modules depend on a Google Sheet to collect the data.  
To populate the Sheet I made three Google Forms and attached them to a single Google Sheet, each Form uses a separated sheet (tab). Then I created two very simple Google Sites to host the Google Sheets, one public with the Message Form that I share with friends and one private to host the Lending and Events Forms which are entered only by me.  
  
## Examples  
  
The **e-spelho** module needs a front-end to display its information.  
Two examples are provided, the best way to understand the implementation is to study them.  
  
`e-spelho-ui-text.py` is a bare minimum implementation showing how to access the **e-spelho** information without any clutter. It only prints the raw data to the console.  
  
`e-spelho-ui-tk` is a complete example that uses Python's Tkinter module to display a graphical interface that is almost ready to use on a device. Along with other features it has it's own timer to display intermediary information like cycling the news, events, calendar and so on.  
  
  
## Acknowledgments  
  
This is a work in progress, was not tested extensively and should contain bugs and mistakes. I have not rebuilt the hardware so this was made just as an exercise for now.  
  
Cheers.  
