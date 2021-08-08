# used in server
git pull
lsof -ti tcp:80 | xargs kill
nohup hexo server -p 80 &