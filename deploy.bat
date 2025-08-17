# deploy.bat
set all_proxy=socks5://127.0.0.1:33211
set http_proxy=http://127.0.0.1:33210
set https_proxy=http://127.0.0.1:33210
hexo clean
hexo generate  
hexo deploy