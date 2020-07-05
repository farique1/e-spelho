'''
A bare minimum front-end example for the smart mirror e-spelho module at:
http://www.github.com/........
'''

import e_spelho as es

# Max display string length
BD_li_len = 60


def ui_clock(data):
    '''Display the clock information from the e-spelho module
    '''
    print()
    print('Display epoch time:', data[1])
    print('Display clock time:', data[2])
    print('Display clock hour 24:', data[3])
    print('Display clock minute:', data[4])
    print('Display clock second:', data[5])
    print('Display clock hour 12:', data[6])
    print('Display clock am pm:', data[7])


def ui_date(data):
    '''Display the date information from the e-spelho module
    '''
    print()
    print('Display date date:', data[1])
    print('Display date year:', data[2])
    print('Display date month:', data[3])
    print('Display date month day:', data[4])
    print('Display date week day:', data[5])
    print('Display date year week:', data[6])


def ui_greetings(data):
    '''Display the greeting information from the e-spelho module
    '''
    print()
    print('Display greeting greeting:', data[1])
    print('Display greeting title:', data[2])
    print('Display greeting phrase:', data[3])


def ui_weather(data):
    '''Display the weather information from the e-spelho module
    '''
    print()
    print('Display weather delay in seconds:', data[1])
    print('Display weather quantities:', str(data[2])[:BD_li_len])
    print('Display weather current:', str(data[3])[:BD_li_len])
    print('Display weather hour 1:', str(data[4][0])[:BD_li_len])
    print('Display weather hour 2:', str(data[4][1])[:BD_li_len])
    print('Display weather day 1:', str(data[5][0])[:BD_li_len])
    print('Display weather day 2:', str(data[5][1])[:BD_li_len])
    print('Display weather day 3:', str(data[5][2])[:BD_li_len])
    print('Display weather day 4:', str(data[5][3])[:BD_li_len])
    print('Display weather day 5:', str(data[5][4])[:BD_li_len])


def ui_news(data):
    '''Display the news information from the e-spelho module
    '''
    print()
    print('Display news 1:', str(data[1])[:BD_li_len])
    print('Display news 2:', str(data[2])[:BD_li_len])
    print('Display news 3:', str(data[3])[:BD_li_len])
    print('Display news 4:', str(data[4])[:BD_li_len])
    print('Display news 5:', str(data[5])[:BD_li_len])


def ui_comics(data):
    '''Display the comics information from the e-spelho module
    '''
    print()
    print('Display comics 1: ', str(data[0][1])[:BD_li_len])
    print('Display comics 2: ', str(data[1][1])[:BD_li_len])


def ui_calendar(data):
    '''Display the calendar information from the e-spelho module
    '''
    print()
    for n, cal in enumerate(data[1:], 1):
        print(f'Display appointment {n}:', str(cal)[:BD_li_len])


def ui_lending(data):
    '''Display the lending information from the e-spelho module
    '''
    print()
    for n, lnd in enumerate(data[1:], 1):
        print(f'Display lending {n}:', str(lnd)[:BD_li_len])


def ui_events(data):
    '''Display the events information from the e-spelho module
    '''
    print()
    for n, eve in enumerate(data[1:], 1):
        print(f'Display event {n}:', str(eve)[:BD_li_len])


def ui_message(data):
    '''Display the message information from the e-spelho module
    '''
    print()
    for n, mes in enumerate(data[1:], 1):
        print(f'Display message {n}:', str(mes)[:BD_li_len])


# Define function calls for the e-spelho module
mirror = es.Espelho(
    ui_clock=ui_clock,
    ui_date=ui_date,
    ui_greetings=ui_greetings,
    ui_weather=ui_weather,
    ui_news=ui_news,
    ui_calendar=ui_calendar,
    ui_lending=ui_lending,
    ui_events=ui_events,
    ui_message=ui_message
)

# Initialize the e-spelho classes
mirror.initialize()

while True:
    # Call the timer on the e-spelho module
    mirror.timer()
