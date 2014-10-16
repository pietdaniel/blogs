Turning 78 images into ASCII art 
=======
Recently I needed to turn a ton of images into ascii art, this articles documents the process.


I started this project because I couldn't find a nice ascii tarot deck. In so, I had to make one.

## First get the images
Shout out to @jeremytarling on this one. He made a ruby app to draw tarot cards entitled 
[ruby-tarot](https://github.com/jeremytarling/ruby-tarot)
It was nice to just clone the repository and get an organized directory of the 
[Rider-Waite](http://en.wikipedia.org/wiki/Rider-Waite_tarot_deck) deck.
The images had to be manipulated before I could process them into ascii art. Simple stuff like remove the color scale, increase contrast, and resize the image. This lead to an amazing discovery.

## Gimp has scheme

```
Filters->Script-fu->Console
```

The browse function has documentation!


So, we need to be able to identify the image. This proved rather difficult. The image list is a pair of vectors in a list, which is odd but you can extract the image from the image list function like this:

```lisp
(define image (car (vector->list (cadr (gimp-image-list)))))
```

Now we can use the image variable in our scale functions.

```lisp
(gimp-image-scale image 150 261)
```

Next step is to change the saturation all the way down, but this takes a drawable. The following invocation will pull the appropriate drawable from our previously defined image.

```lisp
(define drawable (car (gimp-image-get-active-drawable image)))
```

And with the drawable we now crank down the saturation.

```lisp
(gimp-hue-saturation drawable 0 0 0 -100)
```

We can use the drawable to set the brightness and contrast to the necessary values.

```lisp
(gimp-brightness-contrast drawable 60 127)
```



Here is the save method of the image. It takes a drawable, filename, some parameters, a little something extra, and more parameters that dont matter that much. You can find the docs on this in the browse function of 
[the GIMP](https://www.destroyallsoftware.com/talks/the-birth-and-death-of-javascript).
Im just overwriting the files explicitly so the filename will be the image's filename. 

```lisp
(define filename (car (gimp-image-get-filename image)))
(file-jpeg-save 1 image drawable filename filename 1 1 1 1 "love" 1 1 0 0)
```

And of course everyone knows appropriate functions should have their caddr cddddr cddddr always be "love"

```lisp
(caddr (cddddr (cddddr `(file-jpeg-save 1 image drawable filename filename 1 1 1 1 "love" 1 1 0 0)))) => "love"
```

But, I have a ton of files to run this against, so I need to load them as well. Heres the load method that stores the return image in the variable image.

```lisp
(define image (car (file-jpeg-load 1 filename filename)))
```

Reading the 
[tiny Scheme docs](http://www.alphageeksinc.com/tinyscheme/doc-tinyscheme.html)
helped a bit here.

So, I needed a list of all my files, there is probably a better way to list the files in the script-fu editor but I just did this in a text editor with some shell scripts. It seemed faster then trying to list files in gimp.

```lisp
(define images `("00.jpg" "07.jpg" "14.jpg" "21.jpg" "cu07.jpg" "cuqu.jpg" "pe07.jpg" "pequ.jpg" "sw06.jpg" "swpa.jpg" "wa06.jpg" "wapa.jpg" "01.jpg" "08.jpg" "15.jpg" "cu01.jpg" "cu08.jpg" "pe01.jpg" "pe08.jpg" "sw07.jpg" "swqu.jpg" "wa07.jpg" "waqu.jpg" "02.jpg" "09.jpg" "16.jpg" "cu02.jpg" "cu09.jpg" "pe02.jpg" "pe09.jpg" "sw01.jpg" "sw08.jpg" "wa01.jpg" "wa08.jpg" "03.jpg" "10.jpg" "17.jpg" "cu03.jpg" "cu10.jpg" "pe03.jpg" "pe10.jpg" "sw02.jpg" "sw09.jpg" "wa02.jpg" "wa09.jpg" "04.jpg" "11.jpg" "18.jpg" "cu04.jpg" "cuki.jpg" "pe04.jpg" "peki.jpg" "sw03.jpg" "sw10.jpg" "wa03.jpg" "wa10.jpg" "05.jpg" "12.jpg" "19.jpg" "cu05.jpg" "cukn.jpg" "pe05.jpg" "pekn.jpg" "sw04.jpg" "swki.jpg" "wa04.jpg" "waki.jpg" "06.jpg" "13.jpg" "20.jpg" "cu06.jpg" "cupa.jpg" "pe06.jpg" "pepa.jpg" "sw05.jpg" "swkn.jpg" "wa05.jpg" "wakn.jpg"))
```

I was doing this on windows and needed a full path to save. This is explicitly defined below.

```lisp
(define pwd "C:\\Users\\#{your directory jams}")
```

So, now I'm making a list of images with directories, this is just data munging a list of images.

```lisp
(define dir-images (map (lambda x (string-append pwd (car x))) images))
```

The following code is a simple manipulation function. It loads the file, does my desired gimp effects, then saves the file.

```lisp
(define (manipulation filename)
  (define image (car (file-jpeg-load 1 filename filename)))
  (define drawable (car (gimp-image-get-active-drawable image)))
  (gimp-image-scale image 150 261)
  (gimp-hue-saturation drawable 0 0 0 -100)
  (gimp-brightness-contrast drawable 60 127)
  (file-jpeg-save 1 image drawable filename filename 1 1 1 1 "love" 1 1 0 0))
```

Map that over the list of my images and we are done.

```lisp
(map (lambda x (manipulation (car x))) dir-images)
```

easy mode:

```lisp
(define pwd "C:\\Users\\#{your directory jams}")
(define images `("00.jpg" "07.jpg" "14.jpg" "21.jpg" "cu07.jpg" "cuqu.jpg" "pe07.jpg" "pequ.jpg" "sw06.jpg" "swpa.jpg" "wa06.jpg" "wapa.jpg" "01.jpg" "08.jpg" "15.jpg" "cu01.jpg" "cu08.jpg" "pe01.jpg" "pe08.jpg" "sw07.jpg" "swqu.jpg" "wa07.jpg" "waqu.jpg" "02.jpg" "09.jpg" "16.jpg" "cu02.jpg" "cu09.jpg" "pe02.jpg" "pe09.jpg" "sw01.jpg" "sw08.jpg" "wa01.jpg" "wa08.jpg" "03.jpg" "10.jpg" "17.jpg" "cu03.jpg" "cu10.jpg" "pe03.jpg" "pe10.jpg" "sw02.jpg" "sw09.jpg" "wa02.jpg" "wa09.jpg" "04.jpg" "11.jpg" "18.jpg" "cu04.jpg" "cuki.jpg" "pe04.jpg" "peki.jpg" "sw03.jpg" "sw10.jpg" "wa03.jpg" "wa10.jpg" "05.jpg" "12.jpg" "19.jpg" "cu05.jpg" "cukn.jpg" "pe05.jpg" "pekn.jpg" "sw04.jpg" "swki.jpg" "wa04.jpg" "waki.jpg" "06.jpg" "13.jpg" "20.jpg" "cu06.jpg" "cupa.jpg" "pe06.jpg" "pepa.jpg" "sw05.jpg" "swkn.jpg" "wa05.jpg" "wakn.jpg"))
(define dir-images (map (lambda x (string-append pwd (car x))) images))
(define (manipulation filename) (define image (car (file-jpeg-load 0 filename filename))) (define drawable (car (gimp-image-get-active-drawable image))) (gimp-image-scale image 150 261) (gimp-hue-saturation drawable 0 0 0 -100) (gimp-brightness-contrast drawable 60 127) (file-jpeg-save 1 image drawable filename filename 1 1 1 1 "love" 1 1 0 0) #t)
```

## Now that we've cleaned up the images, lets asciify them

I tried out a few methods, my first approach was using web based ascii converters. I was on windows at the time. After this worked mildly well I tried out [jp2a](http://csl.name/jp2a/) which gave better quality results. I'll document both methods.

There are a lot of web based ascii converters, I found [springfrog's](http://www.springfrog.com/converter/ascii-text-art/index.php) to be the best.

This was my first use of [phantomjs](http://phantomjs.org/download.html) which is nice piece of software. Below is a script that chugs the image into springfrogs site and prints out the ascii art.


```javascript
var page = require('webpage').create(),
    system = require('system'),
    fname;
if (system.args.length !== 2) {
    console.log('Usage: run.js filename');
    phantom.exit(1);
} else {
    fname = system.args[1];
    page.open("http://www.springfrog.com/converter/ascii-text-art/index.php", function () {
        page.uploadFile('input[name=image]', fname);
        page.evaluate(function () {
            document.querySelector('form').submit();
        });
        window.setTimeout(function () {
            var text = page.plainText;
            var string = text.split("\n");
            var output = [];
            var record = false;
            var ctr = 0;
            for (var i in string) {
                if (record) {
                    if (ctr >= 1) {
                      output.push(string[i]);
                    }
                    if (ctr == 66) {
                        record = false
                    }
                    ctr++;
                }
                if (string[i].indexOf("Original") != -1) {
                    record = true;
                }
            }
            for (var q in output) {
                console.log(output[q])
            }
            phantom.exit();
        }, 1500);
    });
}
```

I ran this script over the img directory using this simple shell script.

```sh
for file in `ls img/`; do phantomjs.exe run.js usr/$file > ascii/$file".txt"; done;
```

This worked mildly well, but I wanted better results. Hence using [jp2a](http://csl.name/jp2a/).

```sh
for file in `ls img/`; do jp2a --invert usr/$file > ascii/$file".txt"; done;
```
<br>
*fin.*
====
