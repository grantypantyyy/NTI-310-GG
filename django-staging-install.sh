#!/bin/bash

echo "Installing Apache server..."
sudo yum -y install httpd

echo "Starting HTTP service..."
sudo systemctl enable httpd.service

echo "Starting Apache Server..."
sudo systemctl start httpd.service

echo "Cloning jwade005's github..."
sudo yum -y install git
git clone https://github.com/grantypantyyy/NTI-310-GG.git

echo "Restarting HTTP service..."
sudo service httpd restart

echo "Beginning Django Web Framework install..."
echo "Current version of Python:"

python --version

echo "Installing virtualenv to give Django it's own version of Python..."

sudo rpm -iUvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
sudo yum -y install python-pip

sudo pip install virtualenv
cd /opt

# we're going to install our django libs in /opt, often used for optional or add-on

# we want to make this env accessible to the GCloud user because we don't want to have to run it as root

sudo mkdir django
sudo chown -R ggrism01 django
sleep 5
cd django
sudo virtualenv django-env

echo "Activating virtualenv..."

source /opt/django/django-env/bin/activate

echo "To switch out of virtualenv, type deactivate."

echo "Now using this version of Python:"

which python
sudo chown -R ggrism01 /opt/django

echo "Installing Django"

pip install Django

echo "Django admin is version:"

django-admin --version
django-admin startproject project1

echo "Adjusting settings.py allowed_hosts..."
sed -i "s,ALLOWED_HOSTS = \[\],ALLOWED_HOSTS = \['*'\],g" /opt/django/project1/project1/settings.py

echo "This is the new django project directory..."

sudo yum -y install tree
tree project1

echo "Go to https://docs.djangoproject.com/en/1.10/intro/tutorial01/ to begin first Django Project!"

echo "Starting Django server..."

sudo chmod 644 /opt/django/project1/manage.py
sudo setenforce 0

source /opt/django/django-env/bin/activate

cd /opt/django/project1

#echo "Migrating database files..."

#python manage.py migrate

echo "Django is now accessible from the web at [server IP]:8000..."

#prepare django for postgresql integration -- install postgres dev packages

sudo yum -y install python-devel postgresql-devel
sudo yum -y install gcc

#install psycopg2 to allow us to use the project1 database on postgres server

pip install psycopg2

#configure django database settings
ip1=$(gcloud compute instances list | grep postgres-a-test | awk '{print $4}')


sed -i "s/        'ENGINE': 'django.db.backends.sqlite3',/        'ENGINE': 'django.db.backends.postgresql_psycopg2',/g" /opt/django/project1/project1/settings.py
sed -i "s/        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),/        'NAME': 'project1',/g" /opt/django/project1/project1/settings.py
sed -i "80i 'USER': 'project1'," /opt/django/project1/project1/settings.py
sed -i "81i 'PASSWORD': 'P@ssw0rd1'," /opt/django/project1/project1/settings.py
sed -i "82i 'HOST': 'NEEDTOADDIP'," /opt/django/project1/project1/settings.py
sed -i "83i 'PORT': '5432'," /opt/django/project1/project1/settings.py
sed -i "s/'USER': 'project1',/        'USER': 'project1',/g" /opt/django/project1/project1/settings.py
sed -i "s/'PASSWORD': 'P@ssw0rd1',/        'PASSWORD': 'P@ssw0rd1',/g" /opt/django/project1/project1/settings.py
sed -i "s/'HOST': 'NEEDTOADDIP',/        'HOST': '$ip1',/g" /opt/django/project1/project1/settings.py
sed -i "s/'PORT': '5432',/        'PORT': '5432',/g" /opt/django/project1/project1/settings.py


#migrate databasae

cd /opt/django/project1
python manage.py makemigrations #*******
python manage.py migrate

#create user

python manage.py createsuperuser #<-- will allow admin login
#manage.py docs for automataing
#python manage.py syncdb --noinput
echo "from django.contrib.auth.models import User; User.objects.create_superuser('jonathan', 'jwade005@seattlecentral.edu', 'P@ssw0rd1')" | python manage.py shell

#start djanngo server in the background <-- use fg to bring the process to the foreground and ctrl-c to quit
python manage.py runserver 0.0.0.0:8000&
