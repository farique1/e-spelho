'''
A complex front-end example for the smart mirror e-spelho module at:
http://www.github.com/........
'''

import time
from os import path
import tkinter as tk
from tkinter import ttk
from datetime import datetime

from PIL import Image, ImageTk

import e_spelho as es


def get_image(image_file, w, h, module):
    '''Get images for the Tkinter widgets
    image_file  => The image file
    w           => The desired image width
    h           => The desired image height
    modele      => The image module to find its path
    '''
    image_path = MOD_PATH[module]
    image_path = path.join(image_path, image_file)
    image_import = Image.open(image_path)
    image_import = image_import.resize((w, h), Image.ANTIALIAS)
    image_out = ImageTk.PhotoImage(image_import)
    return image_out


def get_remain(day):
    '''Returns a natural language remaing days string
    day => Desired day datetime
    '''
    remain = day - datetime.now()
    try:
        re_text = int(str(remain).split()[0])
        if re_text < 0:
            return 'Atrasado'
        if re_text == 1:
            return 'Amanhã'
    except ValueError:
        today = datetime.strftime(day, '%d')
        event = datetime.strftime(datetime.now(), '%d')
        if today == event:
            return 'Hoje'
        else:
            return 'Amanhã'
    return f'Em {str(re_text)} dias'


def item_quantity(total, current):
    '''Creates a bullet item quantity and position string
    '''
    if total <= 1:
        return ''
    pre = '○ ' * (current - 1)
    pos = total - current
    string = pre + '●' + (pos * ' ○')
    return string


# Constants and global variables
ALL_PATH = 'Modules'
NEW_PATH = path.join(ALL_PATH, 'News')
WEI_PATH = path.join(ALL_PATH, 'Weather', 'Icons')
MOD_PATH = {'weather': WEI_PATH, 'news': NEW_PATH, '': ALL_PATH}
FPP = {'font': 'None, 06'}
FPM = {'font': 'None, 10'}
FMM = {'font': 'None, 15'}
FGM = {'font': 'None, 25'}
FGG = {'font': 'None, 35'}
FXX = {'font': 'None, 70'}
W = {'foreground': 'white'}
G = {'foreground': 'gray'}
N = {'anchor': 'n'}
NE = {'anchor': 'ne'}
NW = {'anchor': 'nw'}

# Time intervals in seconds for the modules update
tick1 = 5
tick2 = 10
tick3 = 15

# Tkinter initialization
root = tk.Tk()
root.geometry("540x960")
root.configure(bg="black")

style = ttk.Style(root)
style.theme_use('classic')
style.configure("TLabel",
                **FPM,
                foreground="white",
                background="black",
                anchor='n')

i_b020 = get_image('Black.png', 20, 20, '')
i_b045 = get_image('Black.png', 45, 45, '')
i_b060 = get_image('Black.png', 60, 60, '')


class UIClock():
    '''Display the clock information from the e-spelho module
    '''
    # This is not needed in this case, we are already importing datetime
    # and generating our own timing, but is here for completion purpose

    def __init__(self):
        self.ckp = (0, 0)
        self.ckpl1 = 12
        x = self.ckp[0]
        y = self.ckp[1] + self.ckpl1

        self.t_clck = ttk.Label(**FXX, **NW)
        self.t_clck.place(x=x, y=y, **NW)
        self.t_scnd = ttk.Label(**FGM, **G, **NW)
        self.t_scnd.place(x=x, y=y + 11, **NW)

    def update(self, data):
        s_clock = f'{data[3]}:{data[4]}'
        s_scnd = data[5]

        self.t_clck.config(text=s_clock)
        n_cwdt = self.t_clck.winfo_width()
        self.t_scnd.place(x=self.ckp[0] + n_cwdt)
        self.t_scnd.config(text=s_scnd)


class UIDate(UIClock):
    '''Display the date information from the e-spelho module
    '''
    # This is more pertinent, we are already importing datetime
    # but we have no day to day timing (although we could make one
    # or call this along with the clock)

    def __init__(self, clk):
        self.t_date = ttk.Label(**FMM, **NW)
        self.t_date.place(x=clk.ckp[0], y=clk.ckp[1], **NW)

    def update(self, data):
        s_date = f'{data[5][2]}, {data[4]} de {data[3][2]} de {data[2]}'

        self.t_date.config(text=s_date)


class UIGreetings():
    '''Display the greetings information from the e-spelho module
    '''

    def __init__(self):
        grp = (270, 750)
        grpl1 = 45

        self.t_grpr = ttk.Label(**FGG)
        self.t_grpr.place(x=grp[0], y=grp[1] + grpl1, **N)
        self.t_grtg = ttk.Label(**FGG)
        self.t_grtg.place(x=grp[0], y=grp[1], **N)

    def update(self, data):
        s_grtg = f'{data[1]}, {data[2]}'

        self.t_grtg.config(text=s_grtg)
        self.t_grpr.config(text=data[3])


class UIWeather():
    '''Display weather information from the e-spelho module
    '''

    def __init__(self):
        wep = (540, 0)
        wepl1 = 52
        wepl2 = 130
        wepl3 = 190
        self.n_qthr = 2
        self.n_qtdy = 5
        self.n_mage = 24
        x = wep[0]
        y = wep[1] + wepl1
        self.l_file = ['Sunrise', 'Pressure', 'Humidity', 'Dew_Point', 'UV_Index',
                       'Clouds_Cover', 'Visibility', 'Wind_Speed', 'Wind_Direction']
        self.l_keys = ['pressure', 'humidity', 'dew_point', 'uvi',
                       'clouds', 'visibility', 'wind_speed', 'wind_deg']
        self.l_dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                       'S', 'SSO', 'SO', 'WSO', 'O', 'ONO', 'NO', 'NNO']

        self.t_temp = ttk.Label(**FXX, **NE)
        self.t_temp.place(x=x - 3, y=y - 15, **NE)
        self.i_feel = get_image('Feels_Like.png', 20, 20, 'weather')
        self.p_feel = ttk.Label()
        self.p_feel.place(x=x - 6, y=y + 32, **NE)

        self.t_tex = []
        self.p_ico = []
        n_decr = 30
        n_posx = wep[0] - 30
        for n, file in enumerate(self.l_file):
            self.i_ico = get_image(f'{file}.png', 20, 20, 'weather')
            self.p_ico.append(ttk.Label(image=self.i_ico))
            self.p_ico[n].image = self.i_ico
            self.p_ico[n].place(x=n_posx, y=wep[1])
            self.t_tex.append(ttk.Label(width=4))
            self.t_tex[n].place(x=n_posx + 13, y=wep[1] + 25, **N)
            n_posx -= n_decr
        self.i_sris = get_image('Sunrise.png', 20, 20, 'weather')
        self.i_sset = get_image('Sunset.png', 20, 20, 'weather')
        self.p_wico = ttk.Label()
        self.p_wico.place(x=x - 240, y=y - 3, **N)
        self.t_wage = ttk.Label(**G, width=20, justify='center')
        self.t_wage.place(x=x - 210, y=wep[1] + wepl2, **N)
        self.p_monp = ttk.Label()
        self.p_monp.place(x=x - 157, y=y + 4, **N)

        self.t_hrp = []
        self.p_hrp = []
        for n in range(self.n_qthr):
            x = wep[0] - 7
            y = wep[1] + wepl2 + (n * 25)
            self.t_hrp.append(ttk.Label(**FMM, **NE))
            self.t_hrp[n].place(x=x, y=y, **NE)
            self.p_hrp.append(ttk.Label())
            self.p_hrp[n].place(x=x - 110, y=y - 3, **NE)

        self.t_dyp = []
        self.p_dyp = []
        self.p_dym = []
        for n in range(self.n_qtdy):
            x = wep[0] - 5
            y = wep[1] + wepl3 + (n * 25)
            self.t_dyp.append(ttk.Label(**FMM, **NE))
            self.t_dyp[n].place(x=x - 30, y=y, **NE)
            self.p_dym.append(ttk.Label())
            self.p_dym[n].place(x=x, y=y, **NE)
            self.p_dyp.append(ttk.Label())
            self.p_dyp[n].place(x=x - 112, y=y, **NE)

    def update(self, data):
        if data:
            self.data = data
            self.show_feels = False
            now = datetime.now().time()
            s_suns = self.data[3]['sunset']
            s_sunr = self.data[3]['sunrise']
            s_vblt = f'{self.data[3]["visibility"] / 1000}k'
            n_degr = self.data[3]['wind_deg']
            n_dedi = round(n_degr / (360. / len(self.l_dirs)))
            s_dirs = self.l_dirs[n_dedi % len(self.l_dirs)]
            f_wico = f'{self.data[3]["weather_icon"]}.png'
            f_monp = f'Moon_Phase_{self.data[3]["moon_phase"]}.png'
            n_wage = self.data[1] // 3600
            s_wage = ''

            if now > s_sunr and now < s_suns:
                self.p_ico[0].config(image=self.i_sset)
                self.t_tex[0].config(text=s_suns.strftime('%H:%M').lstrip('0'))
            else:
                self.p_ico[0].config(image=self.i_sris)
                self.t_tex[0].config(text=s_sunr.strftime('%H:%M').lstrip('0'))
            self.p_ico[0].image = self.i_ico
            for n, key in enumerate(self.l_keys, 1):
                self.t_tex[n].config(text=self.data[3][key])
            self.t_tex[6].config(text=s_vblt)
            self.t_tex[8].config(text=s_dirs)
            self.i_wico = get_image(f_wico, 60, 60, 'weather')
            self.p_wico.config(image=self.i_wico)
            self.p_wico.image = self.i_wico
            self.i_monp = get_image(f_monp, 45, 45, 'weather')
            self.p_monp.configure(image=self.i_monp)
            self.p_monp.image = self.i_monp
            if n_wage > self.n_mage:
                s_wage = f'Dados do clima com\n{n_wage} horas de atraso'
            self.t_wage.config(text=s_wage)

            for n in range(self.n_qthr):
                s_hour = self.data[4][n]["time"].strftime("%H:%M")
                s_tmpd = round(self.data[4][n]["temp"])
                s_tmpd = f'{s_tmpd}º às {s_hour}'
                f_weat = f'{self.data[4][n]["weather_icon"]}.png'

                self.t_hrp[n].config(text=s_tmpd)
                self.i_hrp = get_image(f_weat, 20, 20, 'weather')
                self.p_hrp[n].config(image=self.i_hrp)
                self.p_hrp[n].image = self.i_hrp

            for n in range(self.n_qtdy):
                s_lowt = round(self.data[5][n]['temp_min'])
                s_maxt = round(self.data[5][n]['temp_max'])
                s_wday = self.data[5][n]['weekday'][1]
                s_dayf = f'{s_wday}              {s_lowt}º   {s_maxt}º'
                f_moon = f'Moon_Phase_{self.data[5][n]["moon_phase"]}.png'
                f_weat = f'{self.data[5][n]["weather_icon"]}.png'

                self.t_dyp[n].config(text=s_dayf)
                self.i_dym = get_image(f_moon, 20, 20, 'weather')
                self.p_dym[n].config(image=self.i_dym)
                self.p_dym[n].image = self.i_dym
                self.i_dyp = get_image(f_weat, 20, 20, 'weather')
                self.p_dyp[n].config(image=self.i_dyp)
                self.p_dyp[n].image = self.i_dyp

        if self.show_feels:
            i_temp = self.i_feel
            s_temp = f'{round(self.data[3]["feels_like"])}º'
        else:
            i_temp = i_b020
            s_temp = f'{round(self.data[3]["temp"])}º'
        self.t_temp.config(text=s_temp)
        self.p_feel.config(image=i_temp)
        self.p_feel.image = i_temp
        self.show_feels = not self.show_feels


class UINews():
    '''Display the news information from the e-spelho module
    with or without the QR codes
    '''

    def __init__(self):
        self.length = 5
        self.nep = (2, 205)
        self.nepst = 20
        self.t_new = []

        for n in range(self.length):
            x = self.nep[0]
            y = self.nep[1] + (n * self.nepst)
            self.t_new.append(ttk.Label(**G, **NW))
            self.t_new[n].place(x=x, y=y, **NW)
        self.p_neqr = ttk.Label()
        self.p_neqr.place(x=x, y=y + self.nepst + 3, **NW)
        self.t_smry = ttk.Label(wraplength=230)
        self.t_smry.place(x=x + 50, y=y + self.nepst, **NW)

    def update(self, data):
        if data:
            self.data = data
            self.index = 0
            for n in range(self.length):
                s_titl = self.data[n + 1]['title']
                if len(s_titl) > 55:
                    s_titl = s_titl[:52] + '...'
                self.t_new[n].config(text=s_titl, **G)

        self.index = self.index % (self.length)
        self.t_new[self.index - 1].config(**G)
        self.index += 1
        self.t_new[self.index - 1].config(**W)

        n_sadj = 50
        s_desc = self.data[self.index]['description']
        if self.data[self.index]['qr_image']:
            n_wrpl = 220
            n_maxc = n_wrpl - int(n_sadj * 1.2)
            s_posx = self.nep[0] + n_sadj
            f_qrco = f'news_{self.index}.png'
            i_neqr = get_image(f_qrco, 45, 45, 'news')
        else:
            n_wrpl = 270
            n_maxc = n_wrpl - n_sadj
            s_posx = self.nep[0]
            i_neqr = i_b045

        if len(s_desc) > n_maxc:
            s_desc = s_desc[:n_maxc - 3] + '...'
        s_surc = self.data[self.index]['source']
        s_desc = f'{s_desc}\n - {s_surc}'

        self.t_smry.config(text=s_desc)
        self.t_smry.config(wraplength=n_wrpl)
        self.t_smry.place(x=s_posx)
        self.p_neqr.config(image=i_neqr)
        self.p_neqr.image = i_neqr


class UIComics():
    '''Display Comics information from the e-spelho module
    Left intentionally blank
    '''
    pass


class UICalendar():
    '''Display the calendar information from the e-spelho module
    '''

    def __init__(self):
        self.length = 5
        self.cap = (2, 380)
        self.capst = 20
        self.t_eva = []
        self.t_evt = []

        self.t_evpr = ttk.Label(**G, **NW)
        self.t_evpr.place(x=self.cap[0], y=self.cap[1], **NW)
        for n in range(self.length):
            x = self.cap[0]
            y = self.cap[1] + (self.capst * (n + 1))
            self.t_evt.append(ttk.Label(**G, **NW))
            self.t_evt[n].place(x=x, y=y, **NW)
            self.t_eva.append(ttk.Label(anchor='nw'))
            self.t_eva[n].place(x=x + 40, y=y, **NW)
        self.t_evpo = ttk.Label(**G, **NW)
        self.t_evpo.place(x=x, y=y + self.capst, **NW)

    def update(self, data):
        if data:
            self.data = data
            self.start = 1
            self.end = self.length + 1
            self.size = len(data) - 1

        s_prev = ''
        s_post = ''

        if self.data[1]:
            for n in range(self.start, self.end):
                s_apmt = ''
                s_time = ''

                if n <= self.size:
                    if self.data[n]['all_day']:
                        n_posx = self.cap[0]
                    else:
                        n_posx = self.cap[0] + 40
                        s_time = self.data[n]['start'].strftime('%H:%M')

                    s_apmt = self.data[n]['summary']

                self.t_evt[n - self.start].config(text=s_time)
                self.t_eva[n - self.start].config(text=s_apmt)
                self.t_eva[n - self.start].place(x=n_posx)

            if self.start > 1:
                s_prev = '...'
            if self.size >= self.end:
                s_post = '...'
                self.start += self.length
                self.end += self.length
            else:
                self.start = 1
                self.end = self.length + 1

            self.t_evpr.config(text=s_prev)
            self.t_evpo.config(text=s_post)


class UILending():
    '''Display lending information from the e-spelho module
    '''

    def __init__(self):
        self.length = 5
        self.lep = (535, 320)
        self.lepst = 40
        self.lepl1 = 15
        self.t_lei = []
        self.t_led = []
        self.t_len = []
        self.t_lel = []

        self.t_lepr = ttk.Label(**G, **NE)
        self.t_lepr.place(x=self.lep[0], y=self.lep[1], **NE)
        for n in range(self.length):
            x = self.lep[0]
            y = self.lep[1] + (self.lepst * (n + 1))
            self.t_led.append(ttk.Label(**G, **NE))
            self.t_led[n].place(x=x, y=y - self.lepl1, **NE)
            self.t_lel.append(ttk.Label(**G, **NE))
            self.t_lel[n].place(x=x, y=y, **NE)
            self.t_lei.append(ttk.Label(anchor='ne'))
            self.t_lei[n].place(x=x - 55, y=y - self.lepl1, **NE)
            self.t_len.append(ttk.Label(**G, **NE))
            self.t_len[n].place(x=x - 55, y=y, **NE)
        self.t_lepo = ttk.Label(**G, **NE)
        self.t_lepo.place(x=x, y=y + self.lepl1, **NE)

    def update(self, data):
        if data:
            self.data = data
            self.start = 1
            self.end = self.length + 1
            self.size = len(data) - 1

        s_prev = ''
        s_post = ''

        if self.data[1]:
            for n in range(self.start, self.end):
                s_item = ''
                s_date = ''
                s_name = ''
                s_long = ''

                if n <= self.size:
                    s_item = self.data[n]['item']
                    s_date = self.data[n]['when'].strftime('%d %m %y')
                    s_name = self.data[n]['to_whom']
                    s_long = f'{self.data[n]["how_long"]} dias'

                self.t_led[n - self.start].config(text=s_date)
                self.t_lei[n - self.start].config(text=s_item)
                self.t_len[n - self.start].config(text=s_name)
                self.t_lel[n - self.start].config(text=s_long)

            if self.start > 1:
                s_prev = '...'
            if self.size >= self.end:
                s_post = '...'
                self.start += self.length
                self.end += self.length
            else:
                self.start = 1
                self.end = self.length + 1

            self.t_lepr.config(text=s_prev)
            self.t_lepo.config(text=s_post)


class UIEvents():
    '''Display the events information from the e-spelho module
    '''

    def __init__(self):
        evp = (2, 105)

        self.t_evnt = ttk.Label(**FMM, **NW)
        self.t_evnt.place(x=evp[0], y=evp[1], **NW)
        self.t_desc = ttk.Label(anchor='nw')
        self.t_desc.place(x=evp[0], y=evp[1] + 19, **NW)
        self.t_time = ttk.Label(anchor='nw')
        self.t_time.place(x=evp[0], y=evp[1] + 34, **NW)
        self.t_locl = ttk.Label(anchor='nw')
        self.t_locl.place(x=evp[0], y=evp[1] + 49, **NW)
        self.t_evqu = ttk.Label(**FPP, **G, **NW)
        self.t_evqu.place(x=evp[0], y=evp[1] + 66, **NW)

    def update(self, data):
        if data:
            self.data = data
            self.index = 0

        s_evnt = ''
        s_desc = ''
        s_time = ''
        s_locl = ''
        s_evqu = ''

        if self.data[1]:
            self.index = self.index % (len(self.data) - 1)
            self.index += 1
            s_time = self.data[self.index]["when"]
            s_time = s_time.strftime('%d de %B às %H:%M, %A')
            s_trem = get_remain(self.data[self.index]["when"])

            s_evnt = self.data[self.index]["event"]
            s_desc = self.data[self.index]["description"]
            s_time = f'{s_trem}, {s_time}'
            s_locl = self.data[self.index]["local"]
            s_evqu = item_quantity(len(self.data) - 1, self.index)

        self.t_evnt.config(text=s_evnt)
        self.t_desc.config(text=s_desc)
        self.t_time.config(text=s_time)
        self.t_locl.config(text=s_locl)
        self.t_evqu.config(text=s_evqu)


class UIMessage():
    '''Displays the messages information from the e-spelho module
    '''

    def __init__(self):
        self.mep = (270, 880)
        self.mepl1 = 15
        self.mepl2 = 50
        x = self.mep[0]
        y = self.mep[1]

        self.t_mena = ttk.Label(**G)
        self.t_mena.place(x=x, y=y, **N)
        self.t_mess = ttk.Label(**FGM)
        self.t_mess.place(x=x, y=y + self.mepl1, **N)
        self.t_mequ = ttk.Label(**FPP, **G)
        self.t_mequ.place(x=x, y=y + self.mepl2, **N)

    def update(self, data):
        if data:
            self.data = data
            self.index = 0

        self.s_mena = ''
        self.s_mess = ''
        self.s_mequ = ''

        if self.data[1]:
            self.index = self.index % (len(self.data) - 1)
            self.index += 1
            self.s_quant = item_quantity(len(self.data) - 1, self.index)

            self.s_mena = self.data[self.index]["who"]
            self.s_mess = self.data[self.index]["message"]
            self.s_mequ = self.s_quant

        self.t_mena.config(text=self.s_mena)
        self.t_mess.config(text=self.s_mess)
        self.t_mequ.config(text=self.s_mequ)


# Initialize local classes
class_clock = UIClock()
class_date = UIDate(class_clock)
class_greetings = UIGreetings()
class_weather = UIWeather()
class_news = UINews()
class_calendar = UICalendar()
class_lending = UILending()
class_events = UIEvents()
class_message = UIMessage()

# Define method calls for the e-spelho module
mirror = es.Espelho(
    ui_clock=class_clock.update,
    ui_date=class_date.update,
    ui_greetings=class_greetings.update,
    ui_weather=class_weather.update,
    ui_news=class_news.update,
    ui_calendar=class_calendar.update,
    ui_lending=class_lending.update,
    ui_events=class_events.update,
    ui_message=class_message.update
)

# Initialize the e-spelho classes
mirror.initialize()


def update(time1, time2, time3):
    '''Main timer loop for calling both
    the e-spelho module refresh methods
    and the local update methods
    '''
    # Call the timer on the e-spelho module
    mirror.timer()
    # Call local update methods at the appropriated time
    if time.time() > time1:  # 5 second time loop
        class_message.update(None)
        class_weather.update(None)
        time1 = time.time() + tick1
        root.update()
    if time.time() > time2:  # 10 second time loop
        class_events.update(None)
        class_calendar.update(None)
        class_lending.update(None)
        time2 = time.time() + tick2
        root.update()
    if time.time() > time3:  # 15 second time loop
        class_news.update(None)
        time3 = time.time() + tick3
        root.update()
    # Call the local update module every second
    root.after(1000, update, time1, time2, time3)


time1 = time.time() + tick1
time2 = time.time() + tick2
time3 = time.time() + tick3
root.after(1000, update, time1, time2, time3)
root.mainloop()
