#!/bin/bash

get_env() {
    grep "^$1=" /root/xray.env | cut -d '=' -f2-
}