# Flutter Kokoro TTS Example

## Getting Started

1. Download the necessary model files
Download the following model files:

- [kokoro-v1.0.onnx]("https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx")
- [voices-v1.0.bin]("https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin")

2. Convert the `voices-v1.0.bin` into `voices.json`
Use the example python code below.
```python
import numpy as np
import json

data = np.load("voices-v1.0.bin")

# Export all voices to voices.json
all_voices = {k: v.tolist() for k, v in data.items()}
with open("voices.json", "w") as f:
    json.dump(all_voices, f)

# Optionally, export just af_heart
if "af_heart" in data:
    af_heart = data["af_heart"].tolist()
    with open("af_heart.json", "w") as f:
        json.dump(af_heart, f)
```

3. Place the `kokoro-v1.0.onnx` and `voices.json` files inside `assets` folder.

4. Run `flutter pub get` and start the example application.