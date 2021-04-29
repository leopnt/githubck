#!/usr/bin/env python3

import requests
import subprocess
import os
import sys
import time
import argparse


def get_args_dir():
    my_parser = argparse.ArgumentParser(
        description='Backup github repositories'
        )
    my_parser.add_argument(
        'Username',
        metavar='username',
        type=str,
        help='the github username'
        )

    args = my_parser.parse_args()

    args_dir = {'username':args.Username}
    return args_dir


def get_repos_urls(username):
    # extract urls from github api

    request_url = 'http://api.github.com/users/' + username + '/repos'
    r = requests.get(request_url)
    repos = r.json()
    
    repos_urls = list()
    try:
        for repo in repos:
            if not repo['fork']: # exclude fork repos
                repos_urls.append(repo['clone_url'])
    
    except Exception as e:
        print('Error:', e)
        print('\nRequest status code:', r.status_code)
        print('Please check username and network connection')
        sys.exit()

    return repos_urls


def main(argv):
    username = argv['username']

    urls = get_repos_urls(username)

    t = time.localtime()
    bck_dir = time.strftime("%Y-%m-%d-%H%M%S", t) # name dir with current time

    os.mkdir(bck_dir)
    os.chdir(bck_dir)

    # clone repos into the backup directory
    counter = 0
    for url in urls:
        print('Cloning', url)
        completed = subprocess.run(['git', 'clone', '-q', url])
        if completed.returncode == 0:
            print("Done")
            counter += 1
    
    if counter == 0:
        print('0 repositories detected.')
        os.chdir('..')
        os.rmdir(bck_dir)
    else:
        print('Cloned', counter, 'repositories into', bck_dir)


if __name__ == '__main__':
    main(get_args_dir())
