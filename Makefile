# setting the PATH seems only to work in GNUmake not in BSDmake
PATH := ./testenv/bin:$(PATH)
AWS_ACCESS_KEY_ID = AKIAJ7UVXTSKZ6UFVGPA
AWS_SECRET_ACCESS_KEY = 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
S3BUCKET = s.hdimg.net

cdn:
	echo upload to s3
	s3put-2.6 -a $(AWS_ACCESS_KEY_ID) -s $(AWS_SECRET_ACCESS_KEY) -b $(S3BUCKET) -g public-read -p $(PWD)/media/ media

