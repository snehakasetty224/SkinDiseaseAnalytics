<b>INSTALLATION</b>
1. Install Tensorflow 

>sudo apt-get update && sudo apt-get -y upgrade

>sudo apt-get install python-pip

Verify version
>pip -V
pip 8.1.1 from /usr/lib/python2.7/dist-packages (python 2.7)

>pip install --upgrade pip

>sudo apt-get install python3-pip

>sudo pip3 install virtualenv

>sudo apt-get install python-pip python-dev python-virtualenv

>virtualenv --system-site-packages ~/tensorflow

>source ~/tensorflow/bin/activate

>(tensorflow)$ easy_install -U pip

>(tensorflow)$ pip install --upgrade tensorflow 
 
>(tensorflow)$ deactivate 
 
 
 Anaconda version

Download and copy installer to EC2 Python 2.7 https://www.anaconda.com/download/#linux

bash Anaconda2-5.1.0-Linux-x86_64.sh 

$ conda create -n tensorflow pip python=2.7 # or python=3.3, etc.

$ source activate tensorflow

>pip install --upgrade pip

>pip install --ignore-installed --upgrade
 https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.7.0-cp27-none-linux_x86_64.whl

 >>import tensorflow as tf
 >>print(tf.__version__)
 
 
 
2. Install tflearn

>pip3 install tflearn

3. Download punkt using nltk_data

>sudo pip3 install -U nltk

>python3

>>> import nltk

>>> nltk.download('punkt')

<img width="840" alt="screen shot 2018-04-11 at 4 10 06 pm" src="https://user-images.githubusercontent.com/18491653/38774065-79506944-4013-11e8-916f-3bd8100b488e.png">


<b>STEPS TO CREATE Model</b>

1. Create TfLearn Model
Run chatbot.ipynb notebook on jupyter. It will create model.tflearn data

<img width="665" alt="screen shot 2018-04-14 at 6 50 25 pm" src="https://user-images.githubusercontent.com/18491653/38774098-c11dc036-4014-11e8-9ceb-1112e31fba9b.png">


2. Run tf_freeze.py against the model.tflearn .  :  <python tf_freeze.py --mfolder=model.tflearn>

<img width="876" alt="screen shot 2018-04-14 at 3 00 13 pm" src="https://user-images.githubusercontent.com/18491653/38774055-3a9e6ad4-4013-11e8-9615-6a1522a60fd8.png">

<b> STEPS to CONVERT to mlmodel </b>

  1. Install tf-coreml
  2. Go to utils
  3. Run inspect_pb.py file and generate text file

     python inspect_pb.py frozen_model.pb text_file.txt

  4. Find Softmax at the bottom of generated text file
  
<img width="1143" alt="screen shot 2018-04-14 at 6 25 47 pm" src="https://user-images.githubusercontent.com/18491653/38774026-cf18bae0-4011-11e8-86f1-b7aa90fe711d.png">

  5. Edit the converter.py with softmax value and run
  
 mlmodel file will be generated
<img width="692" alt="screen shot 2018-04-14 at 6 36 35 pm" src="https://user-images.githubusercontent.com/18491653/38774043-f1872016-4012-11e8-838c-509886bfce7a.png">


How to run : 

1. pip install Pyro4

2. pip install flask

3. python -m Pyro4.naming
NS running on localhost:9090 

4. python chatbot.py

5. FLASK_APP=client.py flask run
<img width="666" alt="screen shot 2018-04-17 at 10 07 51 pm" src="https://user-images.githubusercontent.com/18491653/38912738-dbb5a138-428b-11e8-9c9d-ddf05c515775.png">

