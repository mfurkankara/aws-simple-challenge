import subprocess
import smtplib
from email.mime.text import MIMEText
import time
import os

sender_mail = os.environ.get('SENDER_EMAIL')
sender_mail_password = os.environ.get('SENDER_EMAIL_PASSWORD')
received_mail = os.environ.get('RECEIVED_MAIL')

threshold = 90
partition = '/'

def check_disk_usage():
    df = subprocess.Popen(['df','-h'], stdout=subprocess.PIPE)

    for line in df.stdout:
        splitline = line.decode().split()
        if(splitline[5] == partition):
            print(splitline[4][:-1])
            if(int(splitline[4][:-1]) > threshold):
                send_alert_via_mail()



def send_alert_via_mail():
    msg = MIMEText("Disk usage exceeded 90%")
    msg["Subject"] = "Low disk space warning"
    msg["From"] = sender_mail
    msg["To"] = received_mail
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.ehlo()
        server.starttls()
        server.login(sender_mail,sender_mail_password)
        server.sendmail(sender_mail,received_mail,msg.as_string())

while True:
    check_disk_usage()
    time.sleep(300)