## e-spelho  
**Modules output** -- *lists*  
  
>**Module status**  
>`0` Working  
>`1` Currently out -- try again  
>`2` Permanently out -- needs fixing  
>`3` Fatal -- crash possible  
>`4` Naturally blank  
  
***Time***  
`ck_time`  
`[0]` **Status** -- *integer*  
`[1]` **Epoch time** -- *float*  
`[2]` **Current time** -- *datetime*  
`[3]` **Hour** 24h 0 padded -- *string*  
`[4]` **Minutes** 0 padded -- *string*  
`[5]` **Seconds** 0 padded -- *string*  
`[6]` **Hour** 12h 0 padded -- *string*  
`[7]` **AM PM** depends on local -- *string*  
  
***Date***  
`ck_date[6]`  
`[0]` **Status** -- *integer*  
`[1]` **Current date** -- *datetime*  
`[2]` **Year** with century -- *string*  
`[3]` **Month** -- *list*  
-- `[3][0]` **Number** 0 padded -- *string*  
-- `[3][1]` **3 Letter name** local -- *string*  
-- `[3][2]` **Full name** local -- *string*  
`[4]` **Day of month** 0 padded -- *string*  
`[5]` **Weekday** -- *list*  
-- `[5][0]` **Number** Sunday=0 0 padded -- *string*  
-- `[5][1]` **3 Letter name** local -- *string*  
-- `[5][2]` **Full name** local -- *string*  
`[6]` **Number in the year** -- *list*  
-- `[6][0]` **Day** 0 padded -- *string*  
-- `[6][1]` **Week** Sunday=0 0 padded -- *string*  
-- `[6][2]` **Week** Monday=0 0 padded -- *string*  
  
***Greetings***  
`gr_greetings`  
`[0]` **Status** -- *integer*  
`[1]` **Greeting** -- *string*  
`[2]` **Title** -- *string*  
`[3]` **Phrase** -- *string*  
  
***Weather***  
`we_weather`  
`[0]` **Status** -- *integer*  
`[1]` **Weather data age** seconds -- *integer*  
`[2]` **Forecast quantity** -- *tuple*  
-- `[2][0]` **Hourly quantity** -- *integer*  
-- `[2][1]` **Hourly increment** -- *integer*  
-- `[2][2]` **Daily quantity** -- *integer*  
`[3]` **Current weather** -- *dictionary*  
-- `[3]{'dt'}` **Epoch time** -- *integer*  
-- `[3]{'sunrise'}` **Sunrise time** -- *datetime time*  
-- `[3]{'sunset'}` **Sunset time** -- *datetime time*  
-- `[3]{'temp'}` **Temperature** kelvin centigrades Fahrenheit -- *float*  
-- `[3]{'feels_like'}` **Temperature** kelvin centigrades Fahrenheit -- *float*  
-- `[3]{'pressure'}` **Pressure** hPa -- *integer*  
-- `[3]{'humidity'}` **Humidity** percent -- *integer*  
-- `[3]{'dew_point'}` **Condensation point** kelvin centigrades Fahrenheit -- *float*  
-- `[3]{'uvi'}` **Ultraviolet index** -- *float*  
-- `[3]{'clouds'}` **Cloud cover** percent -- *integer*  
-- `[3]{'visibility'}` **Visibility distance** meters -- *integer*  
-- `[3]{'wind_speed'}` **Wind speed** meter/sec miles/hour -- *float*  
-- `[3]{'wind_deg'}` **Wind direction** -- *degrees*  
-- `[3]{'weather_id'}` **Weather condition id** -- *integer*  
-- `[3]{'weather_main'}` **Weather group name** -- *string*  
-- `[3]{'weather_description'}` **Weather subgroup description** local -- *string*  
-- `[3]{'weather_icon'}` **Weather icon id** -- *string*  
-- `[3]{'moon_phase'}` **Moon phase** 0-7 0=new 4=full -- *integer*  
-- `[3]{'moon_light'}` **Moon illumination** percent -- *integer*  
-- `[3]{'time'}` **Prediction time** -- *datetime time*  
`[4]` **Hourly weather** -- *list*  
-- `[4][0]` **Hourly 1** -- *dictionary*  
-- - `[4][0]{'dt'}` **Epoch time** -- *integer*  
-- - `[4][0]{'temp'}` **Temperature** kelvin centigrades Fahrenheit -- *float*  
-- - `[4][0]{'feels_like'}` **Temperature** kelvin centigrades Fahrenheit -- *float*  
-- - `[4][0]{'pressure'}` **Pressure** hPa -- *integer*  
-- - `[4][0]{'humidity'}` **Humidity** percent -- *integer*  
-- - `[4][0]{'dew_point'}` **Condensation point** kelvin centigrades Fahrenheit -- *float*  
-- - `[4][0]{'clouds'}` **Cloud cover** percent -- *integer*  
-- - `[4][0]{'wind_speed'}` **Wind speed** meter/sec miles/hour -- *float*  
-- - `[4][0]{'wind_deg'}` **Wind direction** -- *degrees*  
-- - `[4][0]{'weather_id'}` **Weather condition id** -- *integer*  
-- - `[4][0]{'weather_main'}` **Weather group name** -- *string*  
-- - `[4][0]{'weather_description'}` **Weather subgroup description** local -- *string*  
-- - `[4][0]{'weather_icon'}` **Weather icon id** -- *integer*  
-- - `[4][0]{'rain_1h'}` **Rain amount in one hour** -- *float*  
-- - `[4][0]{'time'}` **Prediction time** -- *datetime time*  
-- `[4][...]` **Same as above**  
`[5]` **Daily weather** -- *list*  
-- `[5][0]` **Daily 1** -- *dictionary*  
-- - `[5][0]{'dt'}` **Epoch time** -- *integer*  
-- - `[5][0]{'sunrise'}` **Sunrise time** -- *datetime time*  
-- - `[5][0]{'sunset'}` **Sunset time** -- *datetime time*  
-- - `[5][0]{'pressure'}` **Pressure** hPa -- *integer*  
-- - `[5][0]{'humidity'}` **Humidity** percent -- *integer*  
-- - `[5][0]{'dew_point'}` **Condensation point** kelvin centigrades Fahrenheit -- *float*  
-- - `[5][0]{'wind_speed'}` **Wind speed** meter/sec miles/hour -- *float*  
-- - `[5][0]{'wind_deg'}` **Wind direction** degrees -- *integer*  
-- - `[5][0]{'clouds'}` **Cloud cover** percent -- *integer*  
-- - `[5][0]{'rain'}` **Rain amount** mm -- *float*  
-- - `[5][0]{'uvi'}` **Ultraviolet index** -- *float*  
-- - `[5][0]{'temp_min'}` **Minimal temperature** Kelvin centigrades Fahrenheit -- *float*  
-- - `[5][0]{'temp_max'}` **Maximal temperature** Kelvin centigrades Fahrenheit -- *float*  
-- - `[5][0]{'weather_id'}` **Weather condition id** -- *integer*  
-- - `[5][0]{'weather_main'}` **Weather group name** -- *string*  
-- - `[5][0]{'weather_description'}` **Weather subgroup description** local -- *string*  
-- - `[5][0]{'weather_icon'}` **Weather icon id** -- *integer*  
-- - `[5][0]{'moon_phase'}` **Moon phase** 0-7 0=new 4=full -- *integer*  
-- - `[5][0]{'moon_light'}` **Moon illumination** percent -- *integer*  
-- - `[5][0]{'weekday'}` **Weekday** -- *list*  
-- - -`[5][0]{'weekday'}[0]` **Number** Sunday=0 -- *string*  
-- - -`[5][0]{'weekday'}[1]` **3 Letter** local -- *string*  
-- - -`[5][0]{'weekday'}[2]` **Full name** local -- *string*  
-- - `[5][0]{'day'}` **Prediction day** -- *datetime date*  
-- `[5][...]` **Same as above**  
  
***News***  
`ne_news`  
`[0]` **Status** -- *integer*  
`[1]` **News 1** -- *dictionary*  
-- `[1]{'author'}` **Article author** -- *string*  
-- `[1]{'title'}` **Article title** -- *string*  
-- `[1]{'description'}` **Article summary** -- *string*  
-- `[1]{'url'}` **Article URL** -- *string*  
-- `[1]{'content'}` **Article text** +-200 characters -- *string*  
-- `[1]{'image_url'}` **Article image URL** -- *string*  
-- `[1]{'published_at'}` **Date and time published** -- *datetime*  
-- `[1]{'source'}` **Article source** -- *string*  
-- `[1]{'source_id'}` **Article source id** -- *string*  
-- `[1]{'source_name'}` **Article source name** -- *string*  
-- `[1]{'qr_image'}` **QR code path** -- *string / none*  
`[...]` **Same as above**  
  
***Comics***  
`co_comics`  
`[0]` **Comic 1** xkcd -- *list*  
-- `[0][0]` **Status** -- *integer*  
-- `[0][1]` **Content** -- *dictionary*  
-- - `[0][1]{'file'}` **Comic image file location** -- *string*  
-- - `[0][1]{'size'}` **Comic image dimensions** -- *tuple*  
-- - - `[0][1]{'size'}[0]` **x** -- *integer*  
-- - - `[0][1]{'size'}[1]` **y** -- *integer*  
`[1]` **Comic 1** SMBC -- *list*  
-- `[1][0]` **Status** -- *integer*  
-- `[1][1]` **Content** -- *dictionary*  
-- - `[1][1]{'file'}` **Comic image file location** -- *string*  
-- - `[1][1]{'size'}` **Comic image dimensions** -- *tuple*  
-- - - `[1][1]{'size'}[0]` **x** -- *integer*  
-- - - `[1][1]{'size'}[1]` **y** -- *integer*  
  
***Calendar***  
`ca_calendar`  
`[0]` **Status** -- *integer*  
`[1]` **Appointment 1** -- *dictionary / none*  
-- `[1]{'status'}` **Status** confirmed, tentative or cancelled -- *string*  
-- `[1]{'summary'}` **Title** -- *string*  
-- `[1]{'description'}` **Description** -- *string*  
-- `[1]{'location'}` **Location** -- *string*  
-- `[1]{'all_day'}` **If takes all day** -- *boolean*  
-- `[1]{'start'}` **Start time** -- *datetime time*  
-- `[1]{'end'}` **End time** -- *datetime time*  
-- `[1]{'duration'}` **Duration** -- *datetime timedelta*  
-- `[1]{'attendees'}` **Attendees** -- *list*  
-- - `[1]{'attendees'}[0]` **Attendee 1** name or email --- *string*  
-- - `[1]{'attendees'}[...]` **Same as above**  
-- `[1]{'attachments'}` **Attachments** -- *list*  
-- - `[1]{'attachments'}[0]` **Attachment 1** file name --- *string*  
-- - `[1]{'attachments'}[...]` **Same as above**  
`[...]` **Same as above**  
  
***Lending***  
`le_lending`  
`[0]` **Status** -- *integer*  
`[1]` **Appointment 1** -- *dictionary / none*  
-- `[1]{'item'}` **Item lent** -- *string*  
-- `[1]{'to_whom'}` **To whom** -- *string*  
-- `[1]{'when'}` **Date lent** -- *datetime date*  
-- `[1]{'how_long'}` **For how long** days -- *integer*  
`[...]` **Same as above**  
  
***Events***  
`ev_events`  
`[0]` **Status** -- *integer*  
`[1]` **Event 1** -- *dictionary / none*  
-- `[1]{'event'}` **Name** -- *string*  
-- `[1]{'description'}` **Description** -- *string*  
-- `[1]{'local'}` **Local** -- *string*  
-- `[1]{'when'}` **Date and time** -- *datetime*  
-- `[1]{'on_time'}` **If the event is yet to happen** -- *boolean*  
`[...]` **Same as above**  
  
***Messages***  
`me_messages`  
`[0]` **Status** -- *integer*  
`[1]` **Message 1** -- *dictionary / none*  
-- `[1]{'sent'}` **Sent date** -- *datetime*  
-- `[1]{'message'}` **Message** -- *string*  
-- `[1]{'who'}` **Who sent** -- *string*  
-- `[1]{'date'}` **Date to display** -- *datetime date*  
`[...]` **Same as above**  
