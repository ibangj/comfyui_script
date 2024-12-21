#!/bin/bash

# Directory Configuration
COMFY_ROOT="./ComfyUI"
MODELS_DIR="$COMFY_ROOT/models"
CONTROLNET_DIR="$MODELS_DIR/controlnet"
CHECKPOINTS_DIR="$MODELS_DIR/checkpoints"
UPSCALE_MODELS_DIR="$MODELS_DIR/upscale_models"

# Create necessary directories
create_directories() {
    echo "Creating directories..."
    mkdir -p "$CONTROLNET_DIR"
    mkdir -p "$CHECKPOINTS_DIR"
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

# Main execution
main() {
    echo "Starting model downloads..."
    
    # Create directories
    create_directories
    
    # Download all models
    download_controlnet
    download_checkpoints
    
    echo "Download complete!"
    echo "Note: Some models might require manual download from Civitai due to API limitations."
    echo "Please check the installation and manually download any missing files."
}

# Run the script
main