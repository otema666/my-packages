#!/bin/bash
print_message() {
  case "$1" in
    "green") echo -e "\e[32m$2\e[0m";;
    "yellow") echo -e "\e[33m$2\e[0m";;
    "red") echo -e "\e[31m$2\e[0m";;
    "cyan") echo -e "\e[36m$2\e[0m";;
    *) echo "$2";;
  esac
}