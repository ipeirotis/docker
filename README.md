# Using Docker to deploy a data science environment

This repository contains our setup and configuration files for setting up a data science environment for the students at NYU/Stern. (Jupyter running Python and R, plus MySQL).

## Instructions for students

* As the simplestoption for having access to a Jupyter server, you can login to [Google Colaboratory](https://colab.research.google.com/) and use the Jupyter notebooks there. The default configuration should be more than sufficient for the "Introduction to Programming" class.

We also a few more options for students (or classes) that want more flexibility, for example the Projects in Programming class:

* [Setup a Jupyter server and MySQL locally, using Docker](https://docs.google.com/document/d/1d9bRGYUSvTGRAqXIJAmH8_SGkXaU5bJ3w3p4IeXgQpo/edit?usp=sharing)

* [Setup a Jupyter server on Google Cloud](https://docs.google.com/document/d/1VpMxGQEBI19tcBmtCldQVqUrzWZAj_LvLF2os0R5IOY/edit?usp=sharing)

* [Setup a MySQL Server on Google Cloud](https://docs.google.com/document/d/1PVebD6JsZfZEeTM918ss8805mrl8pomK9gGQBt2yP2o/edit?usp=sharing)


## Features of JupyterHub installation at NYU

* We provide directly support for Python 3 and R kernels. If you want additional kernels let us know.

* By default each student that logs in gets access to a (containerized) 6CPU / 53Gb Ubuntu machine running Jupyter.

* Auto-sharing notes through Github: If you have class material stored on Github, we can add your class on JupyterHub, and all your notes will appear automatically under the `/notes` folder, when students login: We just need to add the URL of your Github repository in the [courses.yaml](https://github.com/ipeirotis/docker/blob/master/class-tools-infrastructure/docker/kubernetes-su/courses.yaml) file. 

* Resolving conflicts: If you update your notes on Github, and your students have modified the earlier version of the notes, when we fetch the latest version of the notes, we also make a backup of the earlier file that was modified by the student. The [clone_nbs.py](https://github.com/ipeirotis/docker/blob/master/class-tools-infrastructure/docker/kubernetes-su/clone_nbs.py) script is the one that clones the repositories, makes backups of the conflicting notebooks, etc.

* Sharing data files: If you want to share data files that are too big to be stored on Github, we can upload the files on JupyterHub, or we can even setup a mounted folder on JupyterHub, also mounted on your local computer, which you can use to share files with the students. 

* Adding new software/libraries: If you need an additional Python or R library (or some other Unix software) to be available on JupyterHub, we can add it to JupyterHub by simply modifying the configuration [Dockerfile](https://github.com/ipeirotis/docker/blob/master/class-tools-infrastructure/docker/base/Dockerfile). In the future, we plan on supporting Binder, which will allow faculty to configure their software environment directly from their Github repositories.

* Support for nbgrader: We have experimental support for nbgrader built on JupyterHub. Let us know if you want to use it.

* Support for JupyterLab: We have installed JupyterLab as well. If you prefer the JupyterLab interface, just replace the `/tree` in the URL with `/lab`.
