from datetime import datetime
import git
import os
import subprocess
import sys
import shutil
import yaml

backup_pref = 'backup_' + ''.join(list(filter(lambda x: not x == '-', datetime.today().isoformat()[0:10]))) + '_'
username = ''

if 'JUPYTERHUB_USER' in os.environ:
    username = os.getenv('JUPYTERHUB_USER')
else:
    username = os.getenv('NB_USER')

def check_notebooks():
    notebook_dir_path = '/home/' + username + '/notebooks/notes'

    if not os.path.exists(notebook_dir_path):
        os.makedirs(notebook_dir_path)

    with open('courses.yaml') as courses_file:
        repositories = yaml.load(courses_file)

    old_notebook_path = '/'.join(notebook_dir_path.split('/')[:-1])
    for course in repositories['courses']:
        old_directory = old_notebook_path + '/' + course['name']
        directory = notebook_dir_path + '/' + course['instructor'] + '/' + course['name']

        need_to_pull = False
        if not os.path.exists(directory):
            if os.path.exists(old_directory):
                instructor_directory = '/'.join(directory.split('/')[:-1])
                os.makedirs(instructor_directory)
                try:
                    shutil.move(old_directory, instructor_directory)
                    need_to_pull = True
                except shutil.Error as sher:
                    print("Could not move {} to {}: {}".format(old_directory, directory, sher))
            elif course['repo'] is not None and course['repo'] != '':
                os.makedirs(directory)
                subprocess.call(['git', 'clone', course['repo'], directory])
        else:
            need_to_pull = True

        if need_to_pull:
            try:
                repo = git.Repo(directory)
                assert not repo.bare

                if 'JUPYTERHUB_USER' not in os.environ:
                    # overwrite permission changes
                    p = subprocess.Popen('''git diff -p | grep -E \'^(diff|old mode|new mode)\' |
                    sed -e \'s/^old/NEW/;s/^new/old/;s/^NEW/new/\' | git apply''', cwd=directory, shell=True)

                    p.wait()

                # fetch remote repo changes
                repo.remotes.origin.fetch()

                to_checkout = []
                to_overwrite = []
                # get a list of locally modified files which would be
                # overwritten by the pull
                ref = repo.remotes.origin.refs.HEAD
                local_diff = [x.a_path for x in repo.index.diff(None)]
                remote_diff = [x.a_path for x in repo.index.diff(other=ref.commit)]
                files_to_backup = list(set(local_diff).intersection(remote_diff))

                untracked = repo.untracked_files
                for u in untracked:
                    if u in remote_diff:
                        files_to_backup.append(u)

                for changed_file in files_to_backup:
                    path = '/'.join(changed_file.split('/')[:-1])
                    name = changed_file.split('/')[-1]
                    new_path = path + '/' + backup_pref + name
                    subprocess.call(['cp', directory + '/' + changed_file, directory + '/' + new_path])

                    if not (changed_file in untracked):
                        to_checkout.append(changed_file)
                    else:
                        to_overwrite.append((directory + '/' + changed_file, directory + '/' + new_path))
                        os.remove(directory + '/' + changed_file)

                # discard local changes
                repo.index.checkout(paths=to_checkout, force=True)
                # pull remote changes
                repo.remotes.origin.pull()

                for f in to_overwrite:
                    source = f[1]
                    target = f[0]
                    os.rename(source, target)

            except git.InvalidGitRepositoryError:
                print("{} is not a git repo, skipping".format(directory))
            except:
                print("Failed while fetching changes, will backup entire folder and reset")

                if subprocess.call(['cp', '-r', directory, notebook_dir_path + '/' + course['instructor'] + '/' + backup_pref + course['name']]) == 0:
                    try:
                        repo = git.Repo(directory)
                        assert not repo.bare

                        repo.git.reset('--hard', 'origin/HEAD')
                    except:
                        print("Could not reset repo, will clone anew")

                        shutil.rmtree(directory, ignore_errors=True)
                        os.mkdir(directory)
                        subprocess.call(['git', 'clone', course['repo'], directory])
                else:
                    print("Failed while copying " + directory)

def fetch_data():
    data_dir_path = '/home/' + username + '/data'

    if not os.path.exists(data_dir_path):
        os.makedirs(data_dir_path)

    if 'JUPYTERHUB_USER' in os.environ:
        bucket = os.getenv('DATA_BUCKET')
        if subprocess.call(['gcsfuse', '--implicit-dirs', bucket, data_dir_path]):
            print('Failed to mount data bucket')
        else:
            print('Data bucket mounted!')
    else:
        with open('data.yaml') as data_file:
            repositories = yaml.load(data_file)

        for course in repositories['courses']:
            directory = data_dir_path + '/' + course['name']

            if not os.path.exists(directory):
                os.mkdir(directory)
                subprocess.call(['git', 'clone', course['repo'], directory])

check_notebooks()
fetch_data()

#subprocess.call(['sudo', 'ln', '-s', '/home/' + username + '/data/dealing_with_data', '/data'])
