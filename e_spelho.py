'''
e-spelho
Fred Rique (farique) - 2016 - 2019
A smart mirror engine module for delivery of timed, organized,
standardized information to an external graphical front end.
http://www.github.com/........

See the GitHub page for implementation examples.

OBS:
THIS WILL NOT RUN PROPERLY (OR AT ALL) UNLESS YOU HAVE THE
API KEYS AND AUTHENTICATION FILES NECESSARY AND HAVE
IMPLEMENTED THE SUPPORTING EXTERNAL ELEMENTS.
See the GitHub page for full description.

TODO:
- Implement all module status:
    0 = Working
    1 = Currently out (try again)
    2 = Permanently out (fix)
    3 = Fatal (crash possible)
    4 = Naturally blank
- Handle Google authorization, calendar and sheets download errors
- Add alt-text to comics
- Delete news QR codes before making new ones
- Make a 'on_time' entry for the calendar
'''

import time
import logging
import imghdr
import html
import struct
import json
import urllib
import pickle
import locale
from os import path
from random import randrange
from datetime import datetime

from googleapiclient.discovery import build
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow

# DEBUG variables
DEBUG = False
if DEBUG:
    DB_nm_log = True  # Simpler name for the log file
    DB_lp_sec = '%S'  # should be '%S'  Second length g
    DB_lp_min = '%M'  # should be '%M'  Minute length loop
    DB_lp_day = '%M'  # should be '%d'  Day length loop
    DB_lp_hor = '%M'  # should be '%H'  Hour length loop
    DB_we_pri = 'f'  # should be 'u'  Priority source for weather
    DB_ne_pri = 'f'  # should be 'u'  Priority source for News
    DB_co_pri = 'f'  # should be 'u'  Priority source for Comics data
    DB_nw_qrc = True  # Get QR codes from file
    DB_im_url = True  # Ignore image from URL
    DB_gg_aut = True  # Skip Google API authentication
    DB_ca_api = True  # Load calendar from file
    DB_sh_api = True  # Load Google sheets from file
    DB_ds_api = True  # Do not delete past sheet items
else:
    DB_nm_log = False  # Simpler name for the log file
    DB_lp_sec = '%S'  # should be '%S'  Second length loop
    DB_lp_min = '%M'  # should be '%M'  Minute length loop
    DB_lp_day = '%d'  # should be '%d'  Day length loop
    DB_lp_hor = '%H'  # should be '%H'  Hour length loop
    DB_we_pri = 'u'  # should be 'u'  Priority source for weather
    DB_ne_pri = 'u'  # should be 'u'  Priority source for News
    DB_co_pri = 'u'  # should be 'u'  Priority source for Comics data
    DB_nw_qrc = False  # Get QR codes from file
    DB_im_url = False  # Ignore image from URL
    DB_gg_aut = False  # Skip Google API authentication
    DB_ca_api = False  # Load calendar from file
    DB_sh_api = False  # Load Google sheets from file
    DB_ds_api = False  # Do not delete past sheet items

# Global variables and constants

# Installed path
LOCAL_PATH = path.split(path.abspath(__file__))[0]

# Modules path
GREE_PATH = path.join(LOCAL_PATH, 'Modules', 'Greetings')
WEAT_PATH = path.join(LOCAL_PATH, 'Modules', 'Weather')
NEWS_PATH = path.join(LOCAL_PATH, 'Modules', 'News')
COMI_PATH = path.join(LOCAL_PATH, 'Modules', 'Comics')

# Datetime location codes
# af al ar az bg ca cz da de el en eu fa fi fr gl he hi hr hu id it ja kr la lt
# mk no nl pl pt pt_br ro ru sv se sk sl sp es sr th tr ua uk vi zh_cn zh_tw zu
location = 'pt_BR'

# Weather unit type
# default, metric or imperial
units = 'metric'

# Weather forecast hourly quantity, interval and daily quantity
we_qt_horly = 2
we_qt_hstep = 3
we_qt_daily = 5

# News quantity
news_quantity = 5

# News country codes (blank for none)
# ae ar at au be bg br ca ch cn co cu cz de eg fr gb gr
# hk hu id ie il in it jp kr lt lv ma mx my ng nl no nz
# ph pl pt ro rs ru sa se sg si sk th tr tw ua us ve za
news_country = 'br'
news_country = '&country=' + news_country if news_country != '' else ''

# News categories (blank for none)
# business entertainment general health science sports technology
news_category = 'science'
news_category = '&category=' + news_category if news_category != '' else ''

# Make a QR code for the news link
news_qrcode = False

# Get calendar events from current time forward or whole day
calendar_from_now = False

# Date format used on the Sheets
sheet_date_format = '%m/%d/%Y'

# OpenWeatherMap API
# Get at: https://openweathermap.org/api
OWMAPI = '<key>'

# NewsAPI API
# Get at: https://newsapi.org
NEWSAPI = '<key>'

# Lending, Events, and Message Google Sheets spreadsheet ID
# On: https://docs.google.com/spreadsheets/d/<SPREADSID>/edit#gid=<SHEETSID>
SPREADSID = '<ID>'

# Sheets(tabs) name, ID, position
# On: https://docs.google.com/spreadsheets/d/<SPREADSID>/edit#gid=<SHEETSID>
SHEETSID = [('<name>', <ID>, 0),
            ('<name>', <ID>, 1),
            ('<name>', <ID>, 2)]

# Lending, Events, and Message sheet names data range
sheet_range_names = [f'{SHEETSID[0][0]}!B2:D',
                     f'{SHEETSID[1][0]}!B2:E',
                     f'{SHEETSID[2][0]}!A2:D']

# Google API scopes
# If modifying these scopes, delete the file token.pickle.
GOOGLE_SCOPES = ['https://www.googleapis.com/auth/calendar.readonly',
                 'https://www.googleapis.com/auth/spreadsheets']

# Google credentials file
# Must be present
credentials_json = path.join(LOCAL_PATH, 'credentials.json')

# Google autorizations file
# Will be generated from the credentials.json if not present
token_pickle = path.join(LOCAL_PATH, 'token.pickle')


def autenticate():
    '''Authenticate the user on the Google APIs trough the credentials.json
    file and store the access credential on the token.pickle file
    '''
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if path.exists(token_pickle):
        with open(token_pickle, 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                credentials_json, GOOGLE_SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open(token_pickle, 'wb') as token:
            pickle.dump(creds, token)

    service_cal = build('calendar', 'v3', credentials=creds)
    service_she = build('sheets', 'v4', credentials=creds)

    return service_cal, service_she


def download_url(url):
    '''Get URL response from an API.
    url => If str = URL location - get text response
           If tuple = (URL location, image file to save) - get image
           '''
    if url:
        try:
            if type(url) is tuple:
                urllib.request.urlretrieve(url[0], url[1])
                logging.info(f'Image downloaded from: {url[0]}')
                logging.info(f'Image saved to: {url[1]}')
                return url[1]
            else:
                with urllib.request.urlopen(url) as response:
                    html_response = response.read()
                    encoding = response.headers.get_content_charset('utf-8')
                    decoded_html = html_response.decode(encoding)
                    logging.info(f'Data downloaded from: {url}')
                    return decoded_html
        except urllib.error.URLError as e:
            logging.warning(f'Could not access URL: {url}')
            logging.warning(f'  {e}')
    else:
        logging.warning('URL not given')
    return None


def access_file(file=None, oper='r', data=None):
    '''Read or save data to a file with error handling
    file => The file name (can be the only argument when reading)
    oper => 'r' read from the file
            'w' save to the file
    data => The data to be saved
    '''
    if oper.lower() == 'r' or oper.lower() == 'w':
        if oper.lower() == 'r':
            try:
                with open(file, 'r') as f:
                    data = f.read()
                logging.info(f'File read: {file}')
                return data
            except EnvironmentError as e:
                logging.warning(f'Could not read file: {file}')
                logging.warning(f'  {e}')
        else:
            if data:
                try:
                    with open(file, 'w') as f:
                        f.write(data)
                    logging.info(f'File written: {file}')
                except EnvironmentError as e:
                    logging.warning(f'Could not write file: {file}')
                    logging.warning(f'  {e}')
            else:
                logging.error('No data given to write')
    else:
        raise AttributeError('"oper" must be "r" or "w"')
    return None


def get_data(url=None, file=None, pri='f'):
    '''Get data from URL or file depending on availability
    url  => get data from
    file => save or load data
    pri  => 'u' try to get data from url then file
            'f' try to get data from file then url
    '''
    if pri.lower() == 'f' or pri.lower() == 'u':
        if pri.lower() == 'f':
            data = access_file(file=file)
            if not data:
                data = download_url(url)
                if not data:
                    logging.error('Could not retrieve data')
                    return None
                access_file(file=file, oper='w', data=data)
        else:
            data = download_url(url)
            if not data:
                data = access_file(file=file)
                if not data:
                    logging.error('Could not retrieve data')
                    return None
            # use else to not resave the file
            access_file(file=file, oper='w', data=data)
        return data
    else:
        raise AttributeError('"pri" must be "f" or "u"')
        return None


def process_json(data, *keys, value=None):
    '''Convert string to JSON and compare key value
    data  => String to convert
    *keys => Comma separated keys hierarchy to find
    value => Value to compare if key found
    '''
    _data = None
    try:
        data = json.loads(data)
        if len(keys) != 0:
            _data = data
            for key in keys:
                try:
                    _data = _data[key]
                except (KeyError, TypeError):
                    logging.info(f'JSON key does not exist: {key}')
                    return data, None
            if _data and value:
                if _data != value:
                    logging.info(f'JSON value do not match: {_data}')
                    return data, None
        return data, _data
    except json.JSONDecodeError:
        excerp = '"' + data.replace('\n', '') + '"'
        excerp = excerp if len(excerp) <= 81 else excerp[:60] + '[...]"'
        logging.warning(f'JSON failed to decode: {excerp}')
        logging.warning(f'  {excerp}')
    except TypeError:
        logging.warning('JSON failed to read')
    return None, None


def get_image(url, img_file):
    '''Get an image from an URL.
    url      => URL of the image
    img_file => File name to save the image
    '''
    # DEBUG: Below If forces getting image from file not URL
    if DB_im_url:
        has_file = None
    else:
        has_file = download_url((url, img_file))
    if not has_file:
        has_file = path.isfile(img_file)
        if has_file:
            logging.info(f'Image found on: {img_file}')
    if has_file:
        w, h = get_image_size(img_file)  # call dimension retrieve method
        return img_file, (w, h)
    else:
        return None, None


def get_image_size(fname):
    '''Determine the image type of fhandle and return its size.
    from draco
    fname => The image file name to analyze
    '''
    with open(fname, 'rb') as fhandle:
        head = fhandle.read(24)
        if len(head) != 24:
            return
        what_img = imghdr.what(None, head)
        if what_img == 'png':
            check = struct.unpack('>i', head[4:8])[0]
            if check != 0x0d0a1a0a:
                return
            width, height = struct.unpack('>ii', head[16:24])
        elif what_img == 'gif':
            width, height = struct.unpack('<HH', head[6:10])
        elif what_img == 'jpeg':
            try:
                fhandle.seek(0)  # Read 0xff next
                size = 2
                ftype = 0
                while not 0xc0 <= ftype <= 0xcf or ftype in (0xc4, 0xc8, 0xcc):
                    fhandle.seek(size, 1)
                    byte = fhandle.read(1)
                    while ord(byte) == 0xff:
                        byte = fhandle.read(1)
                    ftype = ord(byte)
                    size = struct.unpack('>H', fhandle.read(2))[0] - 2
                # We are at a SOFn block
                fhandle.seek(1, 1)  # Skip `precision' byte.
                height, width = struct.unpack('>HH', fhandle.read(4))
            except Exception:  # IGNORE:W0703
                return
        else:
            return
        return width, height


def string_between(string, first, last):
    '''Get an string between two strings
    string => The string to be searched
    first  => The starting delimiter
    last   => The ending delimiter
    '''
    try:
        start = string.index(first) + len(first)
        end = string.index(last, start)
        return string[start:end]
    except ValueError:
        logging.warning(f"String interval not found: '{first}' ->  '{last}'")
        return None


class Setup():
    '''Configurations
    '''
    locale.setlocale(locale.LC_ALL, location)

    # DEBUG: Below variable should have the timestamp
    date_format = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    if DB_nm_log:
        logname = path.join('log', 'e-spelho.log')
    else:
        logname = path.join('log', f'e-spelho_{date_format}.log')

    # debug, info, warning, error, critical
    loglevel = 'info'
    numeric_level = getattr(logging, loglevel.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError('Invalid log level: %s' % loglevel)
    logging.basicConfig(format='%(asctime)s: %(levelname)s: %(message)s',
                        filename=logname, filemode='w',
                        level=numeric_level)

    # DEBUG: Below IF prevents authentication in debug mode
    if not DB_gg_aut:
        service_cal, service_she = autenticate()


class Espelho():
    '''Main class
    Create objects, initialize them and start the timer
    '''

    def __init__(self, **kw):
        '''Define which objects should be created
        '''
        self.ui_clock = kw.get('ui_clock', None)
        self.ui_date = kw.get('ui_date', None)
        self.ui_greetings = kw.get('ui_greetings', None)
        self.ui_weather = kw.get('ui_weather', None)
        self.ui_news = kw.get('ui_news', None)
        self.ui_comics = kw.get('ui_comics', None)
        self.ui_calendar = kw.get('ui_calendar', None)
        self.ui_lending = kw.get('ui_lending', None)
        self.ui_events = kw.get('ui_events', None)
        self.ui_message = kw.get('ui_message', None)
        if self.ui_lending or self.ui_events or self.ui_message:
            self.ui_get_sheets = True
            self.ui_del_sheet_items = True

    def initialize(self):
        '''Create and initialize the objects and get the start time
        '''
        self.prev_second = datetime.now().strftime(DB_lp_sec)  # DEBUG: %S
        self.prev_minute = datetime.now().strftime(DB_lp_min)  # DEBUG: %M
        self.prev_day = datetime.now().strftime(DB_lp_day)  # DEBUG: %d
        self.prev_hour = datetime.now().strftime(DB_lp_hor)  # DEBUG: %H

        now_date = datetime.now()

        # Initialize classes requested
        if self.ui_clock:
            self.clock = Clock(self.ui_clock, now_date)

        if self.ui_date:
            self.t_date = TDate(self.ui_date, now_date)

        if self.ui_greetings:
            self.greetings = Greetings(self.ui_greetings, now_date)

        if self.ui_weather:
            self.weather = Weather(self.ui_weather, now_date)

        if self.ui_news:
            self.news = News(self.ui_news, now_date)

        if self.ui_comics:
            self.comics = Comics(self.ui_comics, now_date)

        if self.ui_calendar:
            self.calendar = Calendar(self.ui_calendar, now_date)

        # Must come before lending, events or message initialization
        if self.ui_get_sheets:
            self.getsheets = GetSheets(now_date)

        if self.ui_lending:
            values = self.getsheets.values[0]
            self.lending = Lending(values, self.ui_lending, now_date)

        if self.ui_events:
            values = self.getsheets.values[1]
            self.events = Events(values, self.ui_events, now_date)

        if self.ui_message:
            values = self.getsheets.values[2]
            self.message = Message(values, self.ui_message, now_date)

        if self.ui_del_sheet_items:
            self.delsheetitems = DelSheetItems('', '')

    def timer(self):
        '''Get the current time and call the objects refresh methods accordingly
        '''
        now_date = datetime.now()
        now_second = now_date.strftime(DB_lp_sec)  # DEBUG: Correct value is %S
        now_minute = now_date.strftime(DB_lp_min)  # DEBUG: Correct value is %M
        now_hour = now_date.strftime(DB_lp_hor)  # DEBUG: Correct value is %H
        now_day = now_date.strftime(DB_lp_day)  # DEBUG: Correct value is %d

        # Call refresh method on the classes requested
        # The following method calls can be moved to change their periodicity
        if now_second != self.prev_second:

            if self.ui_clock:
                self.clock.refresh(now_date)

            if now_minute != self.prev_minute:

                if now_hour != self.prev_hour:

                    if self.ui_weather:
                        self.weather.refresh(now_date)

                    if now_day != self.prev_day:

                        if self.ui_news:
                            self.news.refresh(now_date)

                        if self.ui_date:
                            self.t_date.refresh(now_date)

                        if self.ui_greetings:
                            self.greetings.refresh(now_date)

                        if self.ui_comics:
                            self.comics.refresh(now_date)

                        if self.ui_calendar:
                            self.calendar.refresh(now_date)

                        # Must come before lending, events or message calls
                        if self.ui_get_sheets:
                            self.getsheets.refresh(now_date)

                        if self.ui_message:
                            values = self.getsheets.values[2]
                            self.message.refresh(values, now_date)

                        if self.ui_lending:
                            values = self.getsheets.values[0]
                            self.lending.refresh(values, now_date)

                        if self.ui_events:
                            values = self.getsheets.values[1]
                            self.events.refresh(values, now_date)

                        if now_day == '01':

                            if self.ui_del_sheet_items:
                                values = self.getsheets.values
                                self.delsheetitems.refresh(values, now_date)

                        self.prev_day = now_day

                    self.prev_hour = now_hour

                self.prev_minute = now_minute

            self.prev_second = now_second


class Clock():
    '''Get the current time
    '''

    def __init__(self, ui_clock, now_date):
        super(Clock, self).__init__()
        self.ui_clock = ui_clock
        self.initialize(now_date)

    def initialize(self, now_date):
        self.ck_time = [''] * 8
        self.ck_time[0] = 0

        self.refresh(now_date)

        logging.info('Initialized Clock')

    def refresh(self, now_date):
        self.ck_time[1] = now_date.timestamp()
        self.ck_time[2] = now_date.time()
        self.ck_time[3] = now_date.strftime('%H')
        self.ck_time[4] = now_date.strftime('%M')
        self.ck_time[5] = now_date.strftime('%S')
        self.ck_time[6] = now_date.strftime('%I')
        self.ck_time[7] = now_date.strftime('%p')

        logging.debug('Refreshed Time')

        self.ui_clock(self.ck_time)


class TDate():
    '''Get the current date
    '''

    def __init__(self, ui_date, now_date):
        super(TDate, self).__init__()
        self.ui_date = ui_date
        self.initialize(now_date)

    def initialize(self, now_date):
        self.da_date = [''] * 7
        self.da_date[0] = 0

        self.refresh(now_date)

        logging.info('Initialized Date')

    def refresh(self, now_date):
        self.da_date[1] = now_date.date()
        self.da_date[2] = now_date.strftime('%Y')
        self.da_date[3] = [now_date.strftime('%m'),
                           now_date.strftime('%b'),
                           now_date.strftime('%B')]
        self.da_date[4] = now_date.strftime('%d')
        self.da_date[5] = [now_date.strftime('%w'),
                           now_date.strftime('%a'),
                           now_date.strftime('%A')]
        self.da_date[6] = [now_date.strftime('%j'),
                           now_date.strftime('%U'),
                           now_date.strftime('%W')]

        logging.info('Refreshed Date')

        self.ui_date(self.da_date)


class Greetings():
    '''Load, randomize and format a custom made greetings list
    '''

    def __init__(self, ui_greetings, now_date):
        super(Greetings, self).__init__()
        self.ui_greetings = ui_greetings
        self.initialize(now_date)

    def initialize(self, now_date):
        text = []
        index = 0
        key = ['greeting', 'title', 'phrase']
        file = path.join(GREE_PATH, 'Greetings.txt')
        self.greetings = {}
        self.gr_greetings = [''] * 4
        self.gr_greetings[0] = 1

        try:
            with open(file, 'r') as f:
                for line in f.readlines():
                    if line.strip() != '-':
                        text.append(line.strip())
                    else:
                        self.greetings[key[index]] = text
                        text = []
                        index += 1
            self.gr_greetings[0] = 1
        except OSError as e:
            logging.warning(e)
        except KeyError as e:
            logging.warning(f'Key not found: {e}')

        self.refresh(now_date)

        logging.info('Initialized Greetings')

    def refresh(self, now_date):
        gr = self.greetings['greeting']
        ti = self.greetings['title']
        ph = self.greetings['phrase']

        self.gr_greetings[1] = gr[randrange(0, len(gr))]
        self.gr_greetings[2] = ti[randrange(0, len(ti))]
        self.gr_greetings[3] = ph[randrange(0, len(ph))]

        logging.info('Refreshed Greetings')

        self.ui_greetings(self.gr_greetings)


class Weather():
    '''Get weather info from OpenWeatherMaps's API One Call
    from the specified time/day and calculates moon phase and luminosity
    '''

    def __init__(self, ui_weather, now_date):
        super(Weather, self).__init__()
        self.ui_weather = ui_weather
        self.initialize(now_date)

    def initialize(self, now_date):
        self.we_weather = [''] * 5
        self.we_weather[0] = 1
        url = 'https://ipinfo.io/json'
        file = path.join(WEAT_PATH, 'GeoIP.json')

        data = get_data(url=url, file=file, pri='f')
        _, data = process_json(data, 'loc')
        if data:
            self.we_weather = [''] * 6
            self.we_weather[0] = 0
            self.we_loc = data.split(',')
            self.refresh(now_date)
        else:
            logging.warning('IP location not found')
            self.we_weather[0] = 1

        if self.we_weather[0] == 0:
            logging.info('Initialized Weather')

    def refresh(self, now_date):
        if self.we_weather[0] == 1:
            self.initialize(now_date)
            return

        url = ('').join(['https://api.openweathermap.org/data/2.5/onecall',
                         '?lat=', self.we_loc[0],
                         '&lon=', self.we_loc[1],
                         '&units=', units,
                         '&lang=', location,
                         '&exclude=minutely',
                         '&appid=', OWMAPI])
        file = path.join(WEAT_PATH, 'Weather_OneCall.json')
        data = get_data(url=url, file=file, pri=DB_we_pri)  # DEBUG: pri is 'u'
        data, response = process_json(data, 'message')

        if data and not response:
            self.we_weather[0] = 0

            self.we_weather[1] = int(time.time()) - data['current']['dt']

            self.we_weather[2] = (we_qt_horly, we_qt_hstep, we_qt_daily)

            self.we_weather[3] = {}
            self.we_weather[4] = []
            self.we_weather[5] = []

            remove = ['weather']
            arg = {i: data['current'][i]
                   for i in data['current'] if i not in remove}
            self.we_weather[3] = arg

            arg = {'weather_' + i: data['current']['weather'][0][i]
                   for i in data['current']['weather'][0]}
            self.we_weather[3].update(arg)

            arg = self.we_weather[3]['sunrise']
            arg = datetime.fromtimestamp(arg).time()
            self.we_weather[3]['sunrise'] = arg

            arg = self.we_weather[3]['sunset']
            arg = datetime.fromtimestamp(arg).time()
            self.we_weather[3]['sunset'] = arg

            arg = self.moon_phase(self.we_weather[3]['dt'])[0]
            self.we_weather[3]['moon_phase'] = arg

            arg = self.moon_phase(self.we_weather[3]['dt'])[1]
            self.we_weather[3]['moon_light'] = arg

            arg = self.we_weather[3]['dt']
            arg = datetime.fromtimestamp(arg).time()
            self.we_weather[3]['time'] = arg

            remove = ['weather', 'rain']
            for j in range(we_qt_horly):
                self.we_weather[4].append({})
                hour = ((j + 1) * we_qt_hstep)

                arg = {i: data['hourly'][hour][i]
                       for i in data['hourly'][hour] if i not in remove}
                self.we_weather[4][j] = arg

                arg = {'weather_' + i: data['hourly'][hour]['weather'][0][i]
                       for i in data['hourly'][hour]['weather'][0]}
                self.we_weather[4][j].update(arg)

                try:
                    arg = {'rain_': data['hourly'][hour]['rain']['1h']}
                    self.we_weather[4][j].update(arg)
                except KeyError:
                    self.we_weather[4][j]['rain_1h'] = 0

                arg = self.we_weather[4][j]['dt']
                arg = datetime.fromtimestamp(arg).time()
                self.we_weather[4][j]['time'] = arg

            remove = ['temp', 'feels_like', 'weather']
            for j in range(we_qt_daily):
                self.we_weather[5].append({})
                day = j + 1

                arg = {i: data['daily'][day][i]
                       for i in data['daily'][day] if i not in remove}
                self.we_weather[5][j] = arg

                arg = self.we_weather[5][j]['sunrise']
                arg = datetime.fromtimestamp(arg).time()
                self.we_weather[5][j]['sunrise'] = arg

                arg = self.we_weather[5][j]['sunset']
                arg = datetime.fromtimestamp(arg).time()
                self.we_weather[5][j]['sunset'] = arg

                arg = data['daily'][day]['temp']['min']
                self.we_weather[5][j]['temp_min'] = arg

                arg = data['daily'][day]['temp']['max']
                self.we_weather[5][j]['temp_max'] = arg

                arg = {'weather_' + i: data['daily'][day]['weather'][0][i]
                       for i in data['daily'][day]['weather'][0]}
                self.we_weather[5][j].update(arg)

                phase, light = self.moon_phase(self.we_weather[5][j]['dt'])
                self.we_weather[5][j]['moon_phase'] = phase
                self.we_weather[5][j]['moon_light'] = light

                day_name = []
                arg = time.localtime(data['daily'][day]['dt'])
                day_name.append(time.strftime('%w', arg))
                day_name.append(time.strftime('%a', arg))
                day_name.append(time.strftime('%A', arg))
                self.we_weather[5][j]['weekday'] = day_name

                arg = self.we_weather[5][j]['dt']
                arg = datetime.fromtimestamp(arg).date()
                self.we_weather[5][j]['day'] = arg

        else:
            self.we_weather[0] = 1
            if response:
                logging.error(response)
            else:
                logging.error('Weather data not found')

        logging.info('Refreshed Weather')

        self.ui_weather(self.we_weather)

    def moon_phase(self, epoch):
        '''Get the moon phase and luminosity according to the date
        '''
        year = int(time.strftime('%Y', time.localtime(epoch)))
        month = int(time.strftime('%m', time.localtime(epoch)))
        day = int(time.strftime('%d', time.localtime(epoch)))

        ages = [18, 0, 11, 22, 3, 14, 25, 6, 17,
                28, 9, 20, 1, 12, 23, 4, 15, 26, 7]
        offsets = [-1, 1, 0, 1, 2, 3, 4, 5, 7, 7, 9, 9]

        if day == 31:
            day = 1
        days_into_phase = ((ages[(year + 1) % 19]
                            + ((day + offsets[month - 1]) % 30)
                            + (year < 1900)) % 30)

        # 0-7. 0 => new moon. 4 => Full moon.
        phase = int((days_into_phase + 2) * 16 / 59.0)
        if phase > 7:
            phase = 7

        # light should be 100% 15 days into phase
        light = int(2 * days_into_phase * 100 / 29)
        if light > 100:
            light = abs(light - 200)

        return phase, light


class News():
    '''Get news from NewsAPI with the configured settings
    and generate a QR code for the link if requested
    '''

    def __init__(self, ui_news, now_date):
        super(News, self).__init__()
        self.ui_news = ui_news
        self.initialize(now_date)

    def initialize(self, now_date):
        self.ne_news = [1]

        self.refresh(now_date)

        logging.info('Initialized News')

    def refresh(self, now_date):
        url = ('').join(['https://newsapi.org/v2/top-headlines',
                         '?pageSize=', str(news_quantity),
                         news_country,
                         news_category,
                         '&apiKey=', NEWSAPI])
        file = path.join(NEWS_PATH, 'NewsAPI.json')
        data = get_data(url=url, file=file, pri=DB_ne_pri)  # DEBUG: pri is 'u'
        data, response = process_json(data, 'status')

        if data and response == 'ok':
            self.ne_news[0] = 0

            remove = ['source']

            for j in range(1, news_quantity + 1):
                self.ne_news.append({})

                arg = {i: data['articles'][j - 1][i]
                       for i in data['articles'][j - 1] if i not in remove}
                self.ne_news[j] = arg

                arg = html.unescape(self.ne_news[j]['title'])
                arg = arg.replace(u'\xa0', u' ')
                arg_split = arg.split(' - ')
                arg = arg_split[0]
                source = arg_split[len(arg_split) - 1]
                self.ne_news[j]['title'] = arg

                arg = html.unescape(self.ne_news[j]['description'])
                arg = arg.replace(u'\xa0', u' ')
                self.ne_news[j]['description'] = arg

                if self.ne_news[j]['content']:
                    arg = html.unescape(self.ne_news[j]['content'])
                    arg = arg.replace(u'\xa0', u' ')
                    arg = arg.replace(u'\r\n', u' ')
                    self.ne_news[j]['content'] = arg

                arg = self.ne_news[j].pop('urlToImage')
                self.ne_news[j]['image_url'] = arg

                arg = self.ne_news[j].pop('publishedAt')
                self.ne_news[j]['published_at'] = arg

                arg = self.ne_news[j]['published_at']
                arg = datetime.strptime(arg, '%Y-%m-%dT%H:%M:%S%z')
                arg = arg.replace(tzinfo=None)
                self.ne_news[j]['published_at'] = arg

                self.ne_news[j]['source'] = source

                arg = data['articles'][j - 1]['source']['id']
                self.ne_news[j]['source_id'] = arg

                arg = data['articles'][j - 1]['source']['name']
                self.ne_news[j]['source_name'] = arg

                qr_link = None
                if news_qrcode:
                    qr_url = ('https://api.qrserver.com/v1/create-qr-code/'
                              '?margin=0'
                              f'&data={self.ne_news[j]["url"]}')
                    qr_file = f'news_{j}.png'
                    qr_image = path.join(NEWS_PATH, qr_file)
                    qr_link = qr_image
                    # DEBUG: Below avoids making QR online if file already exists
                    if DB_nw_qrc:
                        if not path.exists(qr_image):
                            qr_link = download_url((qr_url, qr_image))
                    else:
                        qr_link = download_url((qr_url, qr_image))

                self.ne_news[j]['qr_image'] = qr_link

        else:
            self.ne_news[0] = 1
            if response == 'error':
                logging.error(data['code'])
            else:
                logging.error('News data not found')

        logging.info('Refreshed News')

        self.ui_news(self.ne_news)


class Comics():
    '''Get comics from XKCD and SMBC
    Reads the API/RSS response and get the image file
    '''

    def __init__(self, ui_comics, now_date):
        super(Comics, self).__init__()
        self.ui_comics = ui_comics
        self.initialize(now_date)

    def initialize(self, now_date):
        self.co_comics = [['']] * 2
        self.co_comics[0] = [1, '']
        self.co_comics[1] = [1, '']

        self.refresh(now_date)

        logging.info('Initialized Comics')

    def refresh(self, now_date):
        file, size, status = self.get_comic('xkcd',
                                            'http://xkcd.com/info.0.json',
                                            path.join(COMI_PATH, 'xkcd.json'),
                                            now_date)
        self.co_comics[0] = [status, {'file': file, 'size': size}]

        file, size, status = self.get_comic('SMBC',
                                            'http://www.smbc-comics.com/rss.php',
                                            path.join(COMI_PATH, 'SMBC.xml'),
                                            now_date)
        self.co_comics[1] = [status, {'file': file, 'size': size}]

        logging.info('Refreshed Comics')

        self.ui_comics(self.co_comics)

    def get_comic(self, name, url, file, now_date):
        '''Get comic response and image from APIs
        name => The image file name to save
        url  => The API address and commands
        file => The API response file
        '''
        data = get_data(url=url, file=file, pri=DB_co_pri)  # DEBUG: pri is 'u'
        extension = file.split('.')[len(file.split('.')) - 1]
        if extension.lower() == 'json':
            _, response = process_json(data, 'img')
        else:
            response = string_between(data, 'img src="', '"')
        if response:
            extension = response.split('.')[len(response.split('.')) - 1]
            file_name = f'{name}.{extension}'
            image = path.join(COMI_PATH, file_name)
            img_file, size = get_image(response, image)
            return img_file, size, 0
        else:
            return None, None, 1


class Calendar():
    '''Get calendar appointments (events) from Google Calendar
    '''

    def __init__(self, ui_calendar, now_date):
        super(Calendar, self).__init__()
        self.ui_calendar = ui_calendar
        self.initialize(now_date)

    def initialize(self, now_date):

        self.refresh(now_date)

        logging.info('Initialized Calendar')

    def refresh(self, now_date):
        self.ca_calendar = ['']
        self.ca_calendar[0] = 1

        # DEBUG: Loads API response from a file for debugging
        calendar_response = path.join(LOCAL_PATH, 'calendar.json')
        if DB_ca_api:
            results = access_file(calendar_response)
            results = json.loads(results)
        else:
            timezone = datetime.now().astimezone().tzinfo
            if calendar_from_now:
                now = datetime.now().astimezone(timezone).isoformat()
            else:
                now = datetime.today()
                now = now.replace(hour=0, minute=0,
                                  second=0, microsecond=0)
                now = now.astimezone(timezone).isoformat()
            today = datetime.today()
            today = today.replace(hour=23, minute=59,
                                  second=59, microsecond=999999)
            today = today.astimezone(timezone).isoformat()

            calendar = Setup.service_cal.events()
            results = calendar.list(calendarId='primary',
                                    timeMin=now,
                                    timeMax=today,
                                    singleEvents=True,
                                    orderBy='startTime')
            results = results.execute()

            # DEBUG: Save response as a file for debugging
            # results = str(results).replace("'", '"')
            # results = str(results).replace("False", 'false')
            # results = str(results).replace("True", 'true')
            # access_file(calendar_response, 'w', str(results))
        # END DEBUG

        events = results.get('items', [])

        for event in events:
            self.temp_calendar = {}

            self.temp_calendar['status'] = event.get('status', '')
            self.temp_calendar['summary'] = event.get('summary', '')
            self.temp_calendar['description'] = event.get('description', '')
            self.temp_calendar['location'] = event.get('location', '')

            if event['start'].get('dateTime'):

                self.temp_calendar['all_day'] = False

                temp_srt = event['start'].get('dateTime')
                temp_srt = datetime.strptime(temp_srt, '%Y-%m-%dT%H:%M:%S%z')
                temp_srt = temp_srt.replace(tzinfo=None)
                self.temp_calendar['start'] = temp_srt

                temp_end = event['end'].get('dateTime')
                temp_end = datetime.strptime(temp_end, '%Y-%m-%dT%H:%M:%S%z')
                temp_end = temp_end.replace(tzinfo=None)
                self.temp_calendar['end'] = temp_end

                temp_dur = temp_end - temp_srt
                self.temp_calendar['duration'] = temp_dur
            else:
                self.temp_calendar['all_day'] = True
                self.temp_calendar['start'] = ''
                self.temp_calendar['end'] = ''
                self.temp_calendar['duration'] = ''

            temp_attend = []
            for attendees in event.get('attendees', []):
                temp_attend.append(attendees.get('displayName',
                                                 attendees.get('email')))
            self.temp_calendar['attendees'] = temp_attend

            temp_attach = []
            for attachment in event.get('attachments', []):
                temp_attach.append(attachment.get('title'))
            self.temp_calendar['attachments'] = temp_attach

            self.ca_calendar.append(self.temp_calendar)

        if len(self.ca_calendar) == 1:
            self.ca_calendar[0] = 4
            self.ca_calendar.append(None)

        logging.info('Refreshed Calendar')

        self.ui_calendar(self.ca_calendar)


class GetSheets():
    '''Internal class.
    Get Google Sheets containing Lending, Events and Messages
    Get all in one call for eficiency purposes
    The data for these modules come from sheets on a Google Sheet
    One must be created and populated, ideally using a Google Forms
    The access and ID information is on the global variables
    '''

    def __init__(self, now_date):
        super(GetSheets, self).__init__()
        self.initialize(now_date)

    def initialize(self, now_date):

        self.values = self.refresh(now_date)

        logging.info('Initialized GetSheets')

    def refresh(self, now_date):
        # DEBUG: Loads API response from a file for debugging
        sheet_response = path.join(LOCAL_PATH, 'sheets.json')
        if DB_sh_api:
            results = access_file(sheet_response)
            results = json.loads(results)
        else:
            sheet = Setup.service_she.spreadsheets().values()
            results = sheet.batchGet(spreadsheetId=SPREADSID,
                                     ranges=sheet_range_names)
            results = results.execute()

            # DEBUG: Below saves response as a file for debugging
            # results = str(results).replace("'", '"')
            # access_file(sheet_response, 'w', results)
        # END DEBUG

        self.values = results.get('valueRanges', [])

        logging.info('Refreshed GetSheets')

        return self.values


class Lending():
    '''Get lending list from the appointed Google Sheet
    on sheet [0] in the format:
    Column A: Entry date - not used
    Column B: Item
    Column C: To whom
    Column D: Lending date
    See GetSheets class
    '''

    def __init__(self, values, ui_lending, now_date):
        super(Lending, self).__init__()
        self.ui_lending = ui_lending
        self.initialize(values, now_date)

    def initialize(self, values, now_date):

        self.refresh(values, now_date)

        logging.info('Initialized Lending')

    def refresh(self, values, now_date):
        self.le_lending = ['']
        self.le_lending[0] = 0

        self.values = values.get('values', [])
        for value in self.values:
            self.temp_lending = {}

            self.temp_lending['item'] = value[0]

            self.temp_lending['to_whom'] = value[1]

            date = value[2]
            date = datetime.strptime(date, sheet_date_format)
            self.temp_lending['when'] = date.date()

            how_long = now_date.date() - date.date()
            how_long = str(how_long).split()[0]
            self.temp_lending['how_long'] = int(how_long)

            self.le_lending.append(self.temp_lending)

        if len(self.le_lending) == 1:
            self.le_lending[0] = 4
            self.le_lending.append(None)

        logging.info('Refreshed Lending')

        self.ui_lending(self.le_lending)


class Events():
    '''Get events list from the appointed Google Sheet
    on sheet [1] in the format:
    Column A: Entry date - not used
    Column B: Event
    Column C: Description
    Column D: Place
    Column D: Date and time
    See GetSheets class
    '''

    def __init__(self, values, ui_events, now_date):
        super(Events, self).__init__()
        self.ui_events = ui_events
        self.initialize(values, now_date)

    def initialize(self, values, now_date):

        self.refresh(values, now_date)

        logging.info('Initialized Events')

    def refresh(self, values, now_date):
        self.ev_events = ['']
        self.ev_events[0] = 1

        self.values = values.get('values', [])
        for value in self.values:
            self.temp_event = {}

            date = value[3]
            date = datetime.strptime(date, sheet_date_format + ' %H:%M:%S')

            self.temp_event['event'] = value[0]
            self.temp_event['description'] = value[1]
            self.temp_event['local'] = value[2]
            self.temp_event['when'] = date
            if date >= now_date:
                self.temp_event['on_time'] = True
            else:
                self.temp_event['on_time'] = False

            if date.date() >= now_date.date():
                self.ev_events.append(self.temp_event)

        if len(self.ev_events) == 1:
            self.ev_events[0] = 4
            self.ev_events.append(None)

        logging.info('Refreshed Events')

        self.ui_events(self.ev_events)


class Message():
    '''Get Messages list from the appointed Google Sheet
    on sheet [2] in the format:
    Column A: Entry date
    Column B: Message
    Column C: Who sent
    Column D: Date to show
    See GetSheets class
    '''

    def __init__(self, values, ui_message, now_date):
        super(Message, self).__init__()
        self.ui_message = ui_message
        self.initialize(values, now_date)

    def initialize(self, values, now_date):

        self.refresh(values, now_date)

        logging.info('Initialized Message')

    def refresh(self, values, now_date):
        self.me_message = ['']
        self.me_message[0] = 0

        self.values = values.get('values', [])
        for value in self.values:
            self.temp_message = {}

            sent = value[0]
            sent = datetime.strptime(sent, sheet_date_format + ' %H:%M:%S')

            date = value[3]
            date = datetime.strptime(date, sheet_date_format)

            self.temp_message['sent'] = sent
            self.temp_message['message'] = value[1]
            self.temp_message['who'] = value[2]
            self.temp_message['date'] = date.date()

            if date.date() == now_date.date():
                self.me_message.append(self.temp_message)

        if len(self.me_message) == 1:
            self.me_message[0] = 4
            self.me_message.append(None)

        logging.info('Refreshed Message')

        self.ui_message(self.me_message)


class DelSheetItems():
    '''Internal class.
    Delete past items from the Events and Message sheets on Google Sheets
    '''

    def __init__(self, values, now_date):
        super(DelSheetItems, self).__init__()

    def refresh(self, values, now_date):

        del_ranges = []
        sh_ranges = self.collect_ranges(values[1], SHEETSID[1][1], 3,
                                        ' %H:%M:%S', now_date)
        del_ranges.append(sh_ranges)

        sh_ranges = self.collect_ranges(values[2], SHEETSID[2][1], 3,
                                        '', now_date)
        del_ranges.append(sh_ranges)

        # DEBUG: Prevent from deleting sheet items. Remove if
        if DB_ds_api:
            delete = del_ranges
            results = '*DEBUG: Not deleted*'
        else:
            results, delete = self.delete_ranges(del_ranges, now_date)
        # DEBUG END

        logging.info(f'Deleted sheet items: {delete}')
        logging.info('    {results}')

    def collect_ranges(self, values, sheet_id, date_idx, date_compl, now_date):
        '''Build a list of ranges to delete from the Sheets.
        values     => The Sheet to process
        date_idx   => The x position of the date on the Sheet
        date_compl => A complement for the date, like an hour
        now_date   => The current date, delete everything prior
        '''
        in_range = False
        sh_ranges = [sheet_id]
        self.values = values.get('values', [])

        for n, value in enumerate(self.values, 1):
            self.temp_message = {}
            date = value[date_idx]
            date = datetime.strptime(date, sheet_date_format + date_compl)

            if date.date() < now_date.date():
                if not in_range:
                    srt = n
                    in_range = True
            elif in_range:
                end = n
                sh_ranges.append((srt, end))
                in_range = False
        if in_range:
            end = n + 1
            sh_ranges.append((srt, end))

        return sh_ranges

    def delete_ranges(self, del_ranges, now_date):
        '''Delete ranges from the Sheets
        del_ranges => List of ranges to be deleted
        '''
        delete = []
        results = None
        for sheet_ranges in del_ranges:
            sheet_id = sheet_ranges[0]
            for single_range in sheet_ranges[1:]:
                srt = single_range[0]
                end = single_range[1]
                sh_range = {"deleteDimension": {"range": {"sheetId": sheet_id,
                                                          "dimension": "ROWS",
                                                          "startIndex": srt,
                                                          "endIndex": end}}}
                delete.append(sh_range)

        if delete:
            delete.reverse()
            delete_data = {"requests": delete}
            sheet = Setup.service_she.spreadsheets()
            results = sheet.batchUpdate(spreadsheetId=SPREADSID,
                                        body=delete_data)
            results = results.execute()
        return results, delete


if __name__ == '__main__':
    pass
