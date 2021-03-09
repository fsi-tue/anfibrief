#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.toml

import hashlib
import os
import pprint
import subprocess
import sys

from urllib.request import urlopen

import toml

BASE_URL = 'https://teri.fsi.uni-tuebingen.de/anfibrief/'

with urlopen(BASE_URL + '.BUILDINFO') as http_response:
    BUILDINFO = toml.loads(http_response.read().decode())
    print('Trying to reproduce the following build:')
    pprint.pprint(BUILDINFO)
    src_url = f'https://github.com/fsi-tue/anfibrief/archive/{BUILDINFO["SOURCE_COMMIT"]}.tar.gz'
    nixpkgs_url = f'https://github.com/NixOS/nixpkgs/archive/{BUILDINFO["NIXPKGS_COMMIT"]}.tar.gz'
    env = os.environ.copy()
    env['NIX_PATH'] = f'nixpkgs={nixpkgs_url}'
    # In some cases the following might be required:
    # "git show $NIXPKGS_COMMIT:default.nix | nix-build ..."
    out = subprocess.check_output(['nix-build',
        '--argstr', 'date', BUILDINFO['BUILD_DATE'],
        '--argstr', 'srcUrl', src_url], env=env)
    store_path = out.decode().rstrip('\n')
    print('Hashes:')
    hashes_match = True
    for file_name in os.listdir(store_path):
        with open(os.path.join(store_path, file_name), 'rb') as f:
            local_hash = hashlib.sha256(f.read()).hexdigest()
        with urlopen(BASE_URL + file_name) as http_response:
            remote_hash = hashlib.sha256(http_response.read()).hexdigest()
        if local_hash != remote_hash:
            hashes_match = False
            print(f'- {file_name}: Hashes differ!')
            print(f'  - Local hash:  {local_hash}')
            print(f'  - Remote hash: {remote_hash}')
        else:
            print(f'- {file_name}: Hashes match ({local_hash})')
    print('Result:')
    if hashes_match:
        print('Success, the build was reproducible.')
    else:
        print('Failure! Some hashes differ and therefore the build is not reproducible.')
        sys.exit(1)
