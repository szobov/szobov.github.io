#!/bin/bash

# telegram and linkedin are blocked in Russia
LANG="C.UTF-8" LC_ALL="C.UTF-8" htmlproofer --url-ignore https://t.me/szobov,https://www.linkedin.com/in/szobovdev ${1}
