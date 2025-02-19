#!/bin/bash

# Function to validate and set variables from environment, file, or default
validate_var() {
    local var_name=$1
    local default_value=$2

    # Check if environment variable exists
    if [ -n "${!var_name}" ]; then
        return
    fi

    # Check if file exists with same name as variable
    if [ -f "$var_name" ]; then
        local file_value=$(cat "$var_name")
        eval "$var_name=\$file_value"
        return
    fi

    # If no default value provided, prompt user for input
    if [ -z "$default_value" ]; then
        echo "$var_name not found. Please enter value:"
        read -r user_input
        eval "$var_name=\$user_input"
        # Export to environment
        export "$var_name"
        return
    fi

    # Use default value if neither env var nor file exists
    eval "$var_name=\$default_value"
}

# Function to download file if it doesn't exist
download_if_not_exists() {
    local url=$1
    local output_file=$2
    
    # Create directory if it doesn't exist
    local dir_path=$(dirname "$output_file")
    mkdir -p "$dir_path"

    if [ ! -f "$output_file" ]; then
        echo "Downloading $(basename "$output_file")..."

        headers=""
        if [[ $url == *"huggingface"* ]]; then
            validate_var "HF_TOKEN"
            headers="Authorization: Bearer $HF_TOKEN"
        elif [[ $url == *"civitai"* ]]; then
            validate_var "CIVITAI_TOKEN"
            url="${url}&token=${CIVITAI_TOKEN}"
        fi

        wget -q --show-progress \
            --header="$headers" \
            -O "$output_file" "$url"
    else
        echo "$(basename "$output_file") already exists. Skipping download."
    fi

}

# Function to clone git repository if it doesn't exist
clone_if_not_exists() {
    local repo_url=$1
    local output_dir=$2
    
    if [ ! -d "$output_dir" ]; then
        echo "Cloning $(basename "$output_dir")..."
        git clone "$repo_url" "$output_dir"
    else
        echo "$(basename "$output_dir") already exists. Skipping clone."
    fi
}

validate_var "PROJECT_DIR" "/workspace/ComfyUI"
MODELS_DIR="$PROJECT_DIR/models"

# RealVisXL V5.0 Lightning
download_if_not_exists \
    "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16" \
    "$MODELS_DIR/checkpoints/realvisxlV50_v50LightningBakedvae.safetensors"

# ControlNet Union SDXL
download_if_not_exists \
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors" \
    "$MODELS_DIR/controlnet/sdxl/diffusion_pytorch_model_promax.safetensors"

# CLIP Vision for IP-Adapter
download_if_not_exists \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors" \
    "$MODELS_DIR/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"

# VitMatte (BiRefNet Ultra V2)
clone_if_not_exists \
    "https://huggingface.co/hustvl/vitmatte-small-composition-1k" \
    "$MODELS_DIR/vitmatte"

# Depth Anything V2
mkdir -p "$PROJECT_DIR/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Small"
download_if_not_exists \
    "https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth" \
    "$PROJECT_DIR/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Small/depth_anything_v2_vits.pth"

# Florence-2 Model
clone_if_not_exists \
    "https://huggingface.co/microsoft/Florence-2-base" \
    "$MODELS_DIR/LLM/Florence-2-base"

# IP-Adapter Plus SDXL
download_if_not_exists \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors" \
    "$MODELS_DIR/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors"

echo ""
echo "Launch ComfyUI:"
echo "python main.py"
echo ""
echo "Kill ComfyUI:"
echo "pkill -9 -f 'python main.py'"