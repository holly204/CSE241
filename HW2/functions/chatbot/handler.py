import json
import random
import datetime
import requests

def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """
    if 'name' in req.lower():
        answers = ["name?", "I'm Ruihao! What's your name?", "I'm a bot, and I don't have a name"]
        res = random.choice(answers) 
    elif 'time' in req.lower() or 'date' in req.lower():
        now = datetime.datetime.now()
        date = now.strftime('%Y-%m-%d')
        time = now.strftime('%H:%M:%S')
        answers = ["Now is " + time + " on " + date, date + " " + time, "Today is " + date + " at " + time ]
        res = random.choice(answers)
    elif 'figlet' in req.lower():
        text_to_figlet = req.split()[1::]
        data = {" ".join(text_to_figlet)}
        url = "http://localhost/function/figlet" 
        res = requests.post(url, data=data).stdout.decode('utf-8') 
        return res
        
    else:
        res = "Sorry, I can't answer that."

    return res
