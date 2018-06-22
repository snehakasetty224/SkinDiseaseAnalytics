import tfcoreml as tf_converter
tf_converter.convert(tf_model_path = 'frozen_model.pb',
                     mlmodel_path = 'chatbot_coreml.mlmodel',
                     output_feature_names = ['FullyConnected_2/Softmax:0'],
    				 input_name_shape_dict={'InputData/X:0': [0, 57]}
    				 )

