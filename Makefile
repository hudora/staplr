# setting the PATH seems only to work in GNUmake not in BSDmake
PATH := ./testenv/bin:$(PATH)
S3BUCKET = s.hdimg.net

default:
	@echo "default target"

dependencies:
	virtualenv testenv
	pip -q install -E testenv -r requirements.txt

cdn:
	s3put -a $(AWS_ACCESS_KEY_ID) -s $(AWS_SECRET_ACCESS_KEY) -b $(S3BUCKET) -g public-read -p $(PWD)/media/ media

