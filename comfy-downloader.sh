#!/bin/bash

# Directory Configuration
COMFY_ROOT="./ComfyUI"
MODELS_DIR="$COMFY_ROOT/models"
CONTROLNET_DIR="$MODELS_DIR/controlnet"
CHECKPOINTS_DIR="$MODELS_DIR/checkpoints"
CUSTOM_NODES_DIR="$COMFY_ROOT/custom_nodes"
FACE_MODELS_DIR="$MODELS_DIR/reactor/insightface"
UPSCALE_MODELS_DIR="$MODELS_DIR/upscale_models"

# Create necessary directories
create_directories() {
    echo "Creating directories..."
    mkdir -p "$CONTROLNET_DIR"
    mkdir -p "$CHECKPOINTS_DIR"
    mkdir -p "$CUSTOM_NODES_DIR"
    mkdir -p "$FACE_MODELS_DIR"
    mkdir -p "$UPSCALE_MODELS_DIR"
}

# Download files using aria2c or wget
download_file() {
    local url="$1"
    local output="$2"
    
    if command -v aria2c &> /dev/null; then
        aria2c -x 16 -s 16 "$url" -d "$(dirname "$output")" -o "$(basename "$output")"
    else
        wget -O "$output" "$url"
    fi
}

# Install custom nodes
install_custom_nodes() {
    echo "Installing custom nodes..."
    
    # ReActor Node
    git clone https://github.com/Gourieff/comfyui-reactor-node.git "$CUSTOM_NODES_DIR/comfyui-reactor-node" || echo "Failed to clone ReActor Node"
    
    # Prompt Composer Node
    git clone https://github.com/theUpsider/ComfyUI-Prompt-Composer.git "$CUSTOM_NODES_DIR/ComfyUI-Prompt-Composer" || echo "Failed to clone Prompt Composer"
    
    # Runtime Node
    git clone https://github.com/runtime-assignments/runtime44-comfy.git "$CUSTOM_NODES_DIR/runtime44-comfy" || echo "Failed to clone Runtime Node"

    # Install python dependencies for custom nodes
    if [ -f "$COMFY_ROOT/venv/bin/activate" ]; then
        source "$COMFY_ROOT/venv/bin/activate"
        pip install -r "$CUSTOM_NODES_DIR/comfyui-reactor-node/requirements.txt" || echo "Failed to install ReActor requirements"
        deactivate
    else
        echo "Virtual environment not found. Please install dependencies manually."
    fi
}

# Download ControlNet models
download_controlnet() {
    echo "Downloading ControlNet models..."
    
    # Canny ControlNet LoRA
    download_file "https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank128/control-lora-canny-rank128.safetensors" \
        "$CONTROLNET_DIR/control-lora-canny-rank128.safetensors"
}

# Download checkpoints
download_checkpoints() {
    echo "Downloading model checkpoints..."
    
    # DreamShaperXL Turbo
    download_file "https://civitai.com/api/download/models/251662" \
        "$CHECKPOINTS_DIR/dreamshaperXL_v21TurboDPMSDE.safetensors"
}

# Download ReActor face swap models
download_reactor_models() {
    echo "Downloading ReActor models..."
    
    # inswapper model
    download_file "https://huggingface.co/ezioruan/inswapper_128.onnx/resolve/main/inswapper_128.onnx" \
        "$FACE_MODELS_DIR/inswapper_128.onnx"
    
    # GPEN model
    download_file "https://huggingface.co/henryruhs/gpen/resolve/main/GPEN-BFR-2048.onnx" \
        "$FACE_MODELS_DIR/GPEN-BFR-2048.onnx"
        
    # YOLOv5 face detection model
    download_file "https://github.com/Gourieff/Assets/raw/main/ReActor/YOLOv5n.pt" \
        "$FACE_MODELS_DIR/YOLOv5n.pt"
}

# Main execution
main() {
    echo "Starting ComfyUI components installation..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install git first."
        exit 1
    fi
    
    # Create directories
    create_directories
    
    # Download all components
    download_controlnet
    download_checkpoints
    download_reactor_models
    install_custom_nodes
    
    echo "Installation complete!"
    echo "Note: Some models might require manual download from Civitai due to API limitations."
    echo "Please check the installation and manually download any missing files."
}

# Run the script
main