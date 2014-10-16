# Setting up IPython notebook,

> Recently I needed to do some data analysis for work. I enjoy using matplotlib and needed a solid repl to quickly run some calculations and graph the results. IPython notebook is a great solution for this. This is a quick guide on setting up IPython on linux.

## First install Ipython

##### Dependencies

When installing a few dependencies where required,

- [zmq](http://zeromq.org/), a nice concurrency framework, worth looking to
- [tornado](http://www.tornadoweb.org/en/stable/), web framework with long polling and websockets
- [jinja2](http://jinja.pocoo.org/docs/dev/), template engine

And our dependencies for graphing

- [matplotlib](http://matplotlib.org/), plotting graphs <br>
- [numpy](http://www.numpy.org/), crunching numbers <br>

### Arch

```sh
pacman -S ipython python-pyzmq python-tornado python-matplotlib python-numpy python-jinja
```

### Ubuntu/Debian
The ipython-notebook package includes dependencies

```sh
apt-get install ipython ipython-notebook
```

## Run the notebook

```sh
ipython notebook
```

This will most likely open your default browser, the notebook can viewed at ``localhost:8888`` 

## graph some stuff
Open up a new notebook and enter the following to get started.

First ensure inline mode is enabled

```python
%matplotlib inline
```

Import numpy and matplotlib

```python
import matplotlib.pyplot as plt
import numpy as np
```

Make some cool graphs

```python
x = y = np.arange(-5,5, .1)
xx,yy = np.meshgrid(x, y, sparse=True)
z = np.sin(xx**7 + yy**7)
plt.contourf(x,y,z)
```
<br>
<br>
<br>
*fin.*
====
