import tfcoreml as tf_converter
tf_converter.convert(tf_model_path = 'output_graph.pb',
                     mlmodel_path = 'inception_coreml.mlmodel',
                     output_feature_names = ['final_result:0'],
    				 image_input_names=['Placeholder:0'],
    				 class_labels='skindiseases_class.txt',
    				 input_name_shape_dict={'Placeholder:0': [0, 299, 299, 3]},
    				 red_bias = -1,
                     green_bias = -1,
                     blue_bias = -1,
                     image_scale = 2.0/255.0
    				 )

