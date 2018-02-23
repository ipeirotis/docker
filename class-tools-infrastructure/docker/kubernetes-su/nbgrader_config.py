import os
import subprocess

c = get_config()

username = os.getenv('JUPYTERHUB_USER')

c.Exchange.root = '/home/' + username + '/assignments'
subprocess.call(['sudo', 'chmod', 'ugo+rw', c.Exchange.root])
