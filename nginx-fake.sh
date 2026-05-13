#!/bin/bash

# запуск nginx
systemctl enable nginx
systemctl start nginx

# не надо было заходить :)
echo "<a href=\"https://google.com\">suck my dick</a>" > /var/www/html/index.html