apt update
apt install -y git
mkdir /git
cd /git
git clone -b features/cron https://github.com/dillonchr/hello.git
cd /git/hello/
chmod +x hello.sh
./hello.sh

