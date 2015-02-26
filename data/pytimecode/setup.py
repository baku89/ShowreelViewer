from setuptools import setup, find_packages
setup(name='pytimecode.py', 
		version='0.1.0',
		description="Handles SMPTE Time Code",
		download_url="http://code.google.com/p/pytimecode/downloads/list",
        packages = find_packages(exclude='.svn'),
		long_description="""Module for manipulating SMPTE timecode. Supports 60, 59.94, 50, 30, 29.97, 25, 24, 23.98 frame rates in drop and non-drop where applicable, and milliseconds. It also supports
operator overloading for addition, subtraction, multiplication, and division.

iter_return sets the format that iterations return, the options are "tc" for a timecode string,
"frames" for a int total frames, and "tc_tuple" for a tuple of ints in the following format,
(hours, minutes, seconds, frames).

Notes: *There is a 24 hour SMPTE Timecode limit, so if your time exceeds that limit, it will roll over.
       *2 PyTimeCode objects of the same frame rate is the only supported way to combine PyTimeCode objects, 
            for example adding them together.

Copyright Joshua Banton""",
		classifiers=[
		"Programming Language :: Python",
		("Topic :: Software Development :: Libraries :: Python Modules"),
		],
		keywords='video, timecode',
		author='Joshua Banton',
		author_email='bantonj@gmail.com',
		url='http://bantonj.wordpress.com/software/open-source/',
		license='MIT')
