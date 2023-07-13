# blog

## Usage
bLoG

## Installation
add project to local-projects
for example
cd ~/quicklisp/local-projects
ln -s /home/my-name/projects/blog blog

then start a repl and load the project
(ql:quickload :blog)

now you can start the server
(blog:start :port 8080)


## update instructions

git pull if you have to

tar up the repo

scp tar file to server

un-tar on server and replace /var/www/html dir with tar files

systemcl restart blog.service

(or just run the script './scripts/beam.sh')

# blog service
the blog runs as a systemctl service on the server.
You should put the service file in the etc dir for systemd:
```
/etc/systemd/system/blog.service
```


## Todo
add a model/migrations script ala Django
clean up the css styles

## Author

* <darchuletajr@gmail.com>

## Copyright

Copyright (c) 2023 <darchuletajr@gmail.com>

