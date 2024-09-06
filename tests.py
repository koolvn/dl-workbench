import os

def test_tensorflow():
    try:
        import tensorflow as tf
        print(f"TensorFlow ver. {tf.__version__}")
        tf_gpus = tf.config.list_physical_devices('GPU')
        tf_n_gpus = len(tf_gpus)
        tf_gpus = '\n'.join([str(x) for x in tf_gpus])
        print(f"TensorFlow has found the following GPUs:\n{tf_gpus}" if tf_n_gpus > 0 else "Sorry, GPU is not found by TensorFlow :(((")
    except ImportError:
        print("TensorFlow is not installed.")

def test_pytorch():
    try:
        import torch
        print(f"PyTorch ver. {torch.__version__}")
        torch_n_gpus = torch.cuda.device_count()
        torch_gpus = '\n'.join([torch.cuda.get_device_name(i) for i in range(torch_n_gpus)])
        print(f"PyTorch has found the following GPUs:\n{torch_gpus}" if torch_n_gpus > 0 else "Sorry, GPU is not found by PyTorch :(((")
    except ImportError:
        print("PyTorch is not installed.")

def test_opencv():
    try:
        import cv2
        print(f"OpenCV ver. {cv2.__version__}")
        print("GPU is available and OpenCV can use it!" if cv2.cuda.getCudaEnabledDeviceCount() > 0 else "Sorry, GPU is not found by OpenCV :(((")
    except ImportError:
        print("OpenCV is not installed.")

def main():
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
    from time import sleep

    print('=' * 50)
    print('Performing tests of GPU\'s availability')
    print('=' * 50)
    os.system('nvcc --version')
    os.system('nvidia-smi')
    os.system('nvidia-smi --query-gpu=gpu_name,memory.total --format=csv,noheader')
    sleep(2)
    
    print('=' * 50)
    test_tensorflow()
    
    print('=' * 50)
    test_pytorch()
    
    print('=' * 50)
    test_opencv()
    
    print('=' * 50)

if __name__ == "__main__":
    main()
