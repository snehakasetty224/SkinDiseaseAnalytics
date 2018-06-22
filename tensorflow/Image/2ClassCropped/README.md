INSTALLATION

Install Tensorflow

<b>STEPS TO CREATE Model</b>

Follow the steps to create a model using inception
https://www.tensorflow.org/tutorials/image_retraining

pip install -U tfcoreml

<b>STEPS to CONVERT to mlmodel</b>
  1. Create classes as flower_class txt
  2. Install tf-coreml
  3. Go to utils
  4. Run inspect_pb.py file and generate text file
  
      python inspect_pb.py output_graph_flower.pb flower.txt.txt
  
  5. Find result value at the bottom of generated text file
  
  6. Edit the converter.py with placeholder value and run

  mlmodel file will be generated
  
  <img width="664" alt="screen shot 2018-04-14 at 6 35 41 pm" src="https://user-images.githubusercontent.com/18491653/38774042-f1713dd2-4012-11e8-8330-4ade8ad9c8e5.png">
