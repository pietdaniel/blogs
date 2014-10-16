# Building a simple persistent note board

An [example](http://piet.us/note) can be seen [here](http://piet.us/note). The full source is hosted [here](http://github.com/pietdaniel/notes)

## But why?

> I built this because it's a easy way to transfer small amounts of text to either myself or other individuals over the network. Sometimes I post titles to books or movies, sometimes links to youtube videos, et cetera. There is no built in mechanisms for control so it is a totally free environment. This has caused unexpected yet pleasurable outcomes when notes are left on the board that I did not write.

## The _short_ build phase

----
### Dependencies

The server side of this is just ```flask```. I use the ```SimpleCache``` from the ```werkzeug``` library which is included with ```flask```. Client side uses ```jquery```.

You will need ```python 2.7```.

To install ```flask``` try one of the following:

```sh
$ pip install flask
$ apt-get install python-flask
$ pacman -S python2-flask
```

----
### Server Side

> The server side implementation is just a simple flask ask app that puts data in a cache upon a POST, and returns said data on a GET. There is size validation to ensure huge swaths of data arent being cached. The cache is saved to a file when the program is stopped.

There is a single endpoint that caches the result on a GET method, and validates then saves the text on a POST.  

```python
@app.route("/notes", methods=['GET','POST'])
def notes():
  if request.method == "GET":
    return cache.get('notes')
  if request.method == "POST":
    try:
      data = json.loads(request.data)
      if validate(data['data']):
        cache.set('notes',str(data['data']))
      return data['data']
    except ValueError as e:
      print 'ValueError'
      return 'failed'
```

Validate is a very simple method at the moment,

```python
def validate(text):
  return \
    text is not None and \
    len(text) > 0 and \
    len(text) < 10000
```

When the script is stopped the notes are saved to file.

```python
def exit_handler():
  file = open('/home/notes/notes.txt','w')
  text = urllib.unquote(cache.get('notes')).decode('utf8') 
  file.write(text)
  file.close()
```

I love a good useful simple project. Heres the last bit of the main function

```python
def main():
  cache.set('notes','cache invalid')
  atexit.register(exit_handler)
  app.run(debug=False)
```

#### Improvements

> Well, for one, there was so much I could've done server side to make this more robust. This would've defeated the point of the project. The intent was maximizing utility while minimizing time investment. 

Despite this, some improvements could be:

+ multiple notes via uri scheme, 
+ markdown support
+ stronger validation
+ a history function
+ better save functionality

----
### Client side

> The client side needs to update the textarea initially, then post when changes are made. To resolve this I post against a variety of event handlers. The unload handler should work by itself but the server can easily handle the added overhead and it covers the extremities. 

The post function is a simple ajax call:

```javascript
function post(notes) {
  postData = { "data": notes };
    $.ajax({
      async: false,
      url: "/notes",
      type:"POST",
      headers: {
        "Content-Type": "application/json"
      },
      data: '{"data":"'+encodeURI(notes)+'"}',
      dataType: 'json'
    });
}
```

Here is the event handler code, this may be overkill

```javascript
$(window).unload(function() {
  post($('#notes').val());
});
```

```javascript
$(document).ready(function() {
  console.log("Welcome to the notes");
  $.get("/notes").done(function(r){
    $('#notes').val(decodeURI(r));
  });
  setInterval(function(){
    post($('#notes').val())
  } , 3000)
  $('#notes').focusout(function(){
    post($('#notes').val());
  });
  $("#notes").mouseleave(function() {
    post($('#notes').val());
  });
});
```

#### Style

> For style I just wanted the page to be a single large text area. The CSS for this is pretty straight forward. I enjoy the offwhite coloring of #f0f0f0.

```css
* {
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  padding: 0; 
  margin: 0; 
}
```

```css
textarea {
    left: 0;
    top: 0;
    right: 0;
    height: 100%;
    width: 100%;
    background: #f0f0f0;
}
```

The text area then can be just stuck in the the body.

```html
<textarea id='notes'></textarea>
```

#### Improvements

> The javascript could be far more advanced here. I could finer tune the event handlers while adding more client side features. I could hack together an event driven update system to do live formatting of the posted text, HTML5 could be used to allow for doodles to exist and persist.  The sky is the limit here, yet, once again, the project was intended to be simple: **simple**


----
## Deployment

> This is currently deployed on my piet.us server. I wanted an easy way to start and stop the service, while aggregating log information. For this I used ```init.d``` cause it was available on the server. I also created a new user for the service. 

Running python notes.py will start an instance on localhost:5000

```sh
$ python notes.py
* Running on http://127.0.0.1:5000/
```

With nginx this port can be proxy to

```config
server {
  ...
  location /notes {
    proxy_pass http://127.0.0.1:5000
  }
}
```

Ensure the index.html and notes.js are in there appropriate directories. I use ```/var/www/html``` for this.

> Currently the python script writes it output to ```/home/notes/notes.txt```. This directory will need to exist and have write permissions for the exit handler to function. To resolve this issue, along with facilitating easy start and stops of the service, I used some **quick** init.d scripts.

First, create a new user for the service

```sh
$ useradd -d /home/notes notes
```

The script I wrote calls to external shell scripts, it is located in ```/etc/init.d/notesd```

```sh
 #!/bin/bash
case $1 in
    start)
        /bin/bash /usr/local/bin/notes-start.sh
    ;;
    stop)
        /bin/bash /usr/local/bin/notes-stop.sh
    ;;
    restart)
        /bin/bash /usr/local/bin/notes-stop.sh
        /bin/bash /usr/local/bin/notes-start.sh
    ;;
esac
exit 0
```

Finally the start and stop scripts will run the appropriate commands as the notes user.

For the start script, this redirects logging to a file, the service is run on the default port of localhost:5000

```/usr/local/bin/notes-start.sh```

```sh
 #!/bin/bash
su notes -c "python /home/notes/notes.py 2&> /home/notes/notes.log &"
```

The stop script, well, ok it may be a little draconian. The pid is grabbed through a ridiculous series of shell commands. Then a kill comand is sent to the given pid.

```/bin/bash /usr/local/bin/notes-stop.sh```

```sh
 #!/bin/bash
echo "Ending notes service"
pid=`ps aux | grep notes.py | grep -v grep | awk '{print $2}'`
su notes -c "kill -s SIGTERM $pid"
```

All of this was quick and dirty but it allows me to reset the service quickly.

```sh
$ service notesd start
```

----
## Final Thoughts

> Really this was a quick fun project to kill some time. In the process I got to get more familiar with some cool technologies and enjoyed solving the problems with minimal effort. A working copy can be viewed on my site [here](http://piet.us/note). As well as the source code on my [github](http://github.com/pietdaniel/notes)
<br>
<br>
<br>
*fin.*
====
