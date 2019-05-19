#!/bin/bash

# telegram and linkedin are blocked in Russia
htmlproofer --url-ignore https://t.me/szobov,https://www.linkedin.com/in/szobovdev ${1}
