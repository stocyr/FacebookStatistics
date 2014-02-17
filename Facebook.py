import os.path
import os
from urllib import urlretrieve
import imp
import re,datetime
import fbconsole

def handle_photo(photo, photo_name):
    print "-->Downloading photo", photo_name
    text_file_path = os.path.join(album_dirname, photo_name+'.txt')
    text_file = open(text_file_path, "w");
    if 'name' in photo:
        caption = photo['name'].encode('UTF-8')
        print "    caption:", caption.replace('\n', '\n    ')
        text_file.write(caption);
        text_file.write("\r\n\r\n");
    else:
        print "    no caption available"
    # warning: this ignores the timezone information! ( ..[:-1].. )
    created_time = datetime.datetime(*map(int, re.split('\D', photo['created_time'])[:-1]))
    created_time_formatted = created_time.strftime('%d.%m.%Y %H:%M:%S')
    text_file.write("Timestamp: " + created_time_formatted);
    global_date_file.write(created_time_formatted + "\r\n")
    text_file.close()
    image_url = photo['images'][0]['source']
    urlretrieve(image_url, photo_path)

# BBB Fan Page: 111612552283016

fbconsole.AUTH_SCOPE = ['manage_pages', 'user_photos']
fbconsole.authenticate()
 
#page_id = raw_input("enter the id of the page:")
page_id = '111612552283016'
 
page = fbconsole.get('/'+page_id)
 
dirname = os.path.join(os.path.dirname(__file__), page.get('name'))
if not os.path.exists(dirname):
    os.mkdir(dirname)
 
albums = fbconsole.get('/'+page_id+'/albums', {'limit':500})
print "Found", len(albums), "albums"

global_date_file = open(os.path.join(os.path.dirname(__file__), 'dates.txt'), "w")
 
for album in albums.get('data', []):
    album_dirname = os.path.join(dirname, album.get('name'))
    print "\r\n###############################################################################"
    print "Downloading album", album.get('name') + "(" + str(album.get('count')) + " photos)"
    print "###############################################################################"
    if not os.path.exists(album_dirname):
        os.mkdir(album_dirname)

    if album.get('count') > 100:
        # this has to be done because there's an API limitation of max 100 photos!
        print "==> Fetching first 100 photos first!"
        photos = fbconsole.get('/'+album['id']+'/photos', {'limit':1000})
        for ii, photo in enumerate(photos.get('data', [])):
            photo_name = '%s-%s' % (album.get('name'), ii)
            photo_path = os.path.join(album_dirname, photo_name+'.jpg')
            if not os.path.exists(photo_path):
                handle_photo(photo, photo_name)

        date = raw_input("Please enter the date of the 100th photo: ") # example: "1 january 2012"
        photos = fbconsole.get('/'+album['id']+'/photos', {'until':date, 'limit':1000})
        print "###############################################################################"
        print "==> Now fetching remaining " + str(len(photos.get('data', []))) + " photos."
        for ii, photo in enumerate(photos.get('data', [])):
            photo_name = '%s-%s' % (album.get('name'), ii+100)
            photo_path = os.path.join(album_dirname, photo_name+'.jpg')
            if not os.path.exists(photo_path):
                handle_photo(photo, photo_name)
    else:
        photos = fbconsole.get('/'+album['id']+'/photos', {'limit':1000})
        for ii, photo in enumerate(photos.get('data', [])):
            photo_name = '%s-%s' % (album.get('name'), ii)
            photo_path = os.path.join(album_dirname, photo_name+'.jpg')
            if not os.path.exists(photo_path):
                handle_photo(photo, photo_name)
global_date_file.close()
 
print "All Done!"

fbconsole.logout()
