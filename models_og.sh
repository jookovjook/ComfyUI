#!/bin/bash

# Function to fetch and handle tokens
fetch_token() {
    local token_name=$1
    local token_file="$token_name"
    local token_value
    local auto_save=true # Variable to control automatic token saving

    # Check if environment variable exists and is not empty
    if [ -n "${!token_name}" ]; then
        return
    fi

    if [ -f "$token_file" ]; then
        token_value=$(cat "$token_file")
    else
        echo "$token_name file not found. Please enter your $token_name:"
        read -r token_input
        if [ -f "$token_input" ]; then
            token_value=$(cat "$token_input")
        else
            token_value=$token_input
            if [ "$auto_save" = true ]; then
                echo "$token_value" > "$token_file"
                echo "Token automatically saved to $token_file file."
            else
                echo "Do you want to save this token to the default token file location? (y/n)"
                read -r save_token
                if [ "$save_token" = "y" ] || [ "$save_token" = "Y" ]; then
                    echo "$token_value" > "$token_file"
                    echo "Token saved to $token_file file."
                else
                    echo "Token not saved. It will be used only for this session."
                fi
            fi
        fi
    fi
    eval "$token_name=\$token_value"
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
            headers="Authorization: Bearer $HF_TOKEN"
        elif [[ $url == *"civitai"* ]]; then
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

# Init
if [ -z "${PROJECT_DIR}" ]; then
    DEFAULT_PROJECT_DIR="/workspace/ComfyUI"

    echo "PROJECT_DIR is not specified. Using '$DEFAULT_PROJECT_DIR' by default in 5 seconds..."
    echo "Press N to specify a different directory, Y or nothing to continue with default"
    
    for i in {5..1}; do
        read -t 1 -n 1 key
        if [[ $? -eq 0 ]]; then
            if [[ "$key" == "n" ]] || [[ "$key" == "N" ]]; then
                echo -e "\nPlease enter the project directory path:"
                read -r PROJECT_DIR
                echo "Do you want to save this path for future use? (y/n)"
                read -r save_path
                if [ "$save_path" = "y" ] || [ "$save_path" = "Y" ]; then
                    echo "PROJECT_DIR=$PROJECT_DIR" > .env
                    echo "Path saved to .env file"
                fi
                break
            elif [[ "$key" == "y" ]] || [[ "$key" == "Y" ]]; then
                PROJECT_DIR="$DEFAULT_PROJECT_DIR"
                break
            fi
        fi
        echo "$i..."
    done

    if [ -z "${PROJECT_DIR}" ]; then
        PROJECT_DIR="$DEFAULT_PROJECT_DIR"
    fi
fi
MODELS_DIR="$PROJECT_DIR/models"

# Fetch HF_TOKEN and CIVITAI_TOKEN
fetch_token "HF_TOKEN"
fetch_token "CIVITAI_TOKEN"

# https://www.patreon.com/posts/exclusive-and-120427954

# Group: 0_Playground

# # ControlNet SDXL Depth
# download_if_not_exists \
#     "https://huggingface.co/ckpt/controlnet-sdxl-1.0/resolve/main/diffusers_xl_depth_mid.safetensors" \
#     "$MODELS_DIR/controlnet/sdxl/diffusers_xl_depth_mid.safetensors"

# # T2I-Adapter SDXL Depth (MiDaS)
# download_if_not_exists \
#     "https://huggingface.co/TencentARC/t2i-adapter-depth-midas-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" \
#     "$MODELS_DIR/t2i_adapter/sdxl_depth_midas.safetensors"

# Group: 1_Setting

# RealVisXL V5.0 Lightning
download_if_not_exists \
    "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16" \
    "$MODELS_DIR/checkpoints/realvisxlV50_v50LightningBakedvae.safetensors"


    

# ControlNet Union SDXL
download_if_not_exists \
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors" \
    "$MODELS_DIR/controlnet/sdxl/diffusion_pytorch_model_promax.safetensors"

# LayerMask: Load BiRefNet Model V2
git clone https://mcLigero:$HF_TOKEN@huggingface.co/mcLigero/BiRefNet $PROJECT_DIR/models/BiRefNet
# # Create relative symlinks for BiRefNet files/dirs
# cd "$MODELS_DIR"
# for item in BiRefNet/*; do
#     if [ -e "$item" ] && [ "$item" != "BiRefNet/.git" ]; then
#         base_name=$(basename "$item")
#         target="BiRefNet/$base_name"
        
#         # Check if link already exists and points to correct target
#         if [ -L "$base_name" ]; then
#             current_target=$(readlink "$base_name")
#             if [ "$current_target" = "$target" ]; then
#                 echo "Link '$base_name' -> '$target' is OK"
#                 continue # Skip if link exists and points to correct target
#             fi
#         fi
        
#         # Check if file/dir exists but is not a link or points elsewhere
#         if [ -e "$base_name" ]; then
#             echo "Error: '$base_name' already exists and is not the correct symlink"
#             exit 1
#         fi
        
#         echo "Creating symlink: $base_name -> $target"
#         ln -sf "$target" "$base_name"
        
#     fi
# done
# # cd - > /dev/null
# cd "$(dirname "$0")" > /dev/null

# CLIP Vision for IP-Adapter
download_if_not_exists \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors" \
    "$MODELS_DIR/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"


# Group: 2_Remove Background

# VitMatte (BiRefNet Ultra V2)
clone_if_not_exists \
    "https://huggingface.co/hustvl/vitmatte-small-composition-1k" \
    "$MODELS_DIR/vitmatte"

# Group: 3_Position Your Subject

# Depth Anything V2
mkdir -p "$PROJECT_DIR/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Small"
download_if_not_exists \
    "https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth" \
    "$PROJECT_DIR/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Small/depth_anything_v2_vits.pth"

# Florence-2 Model
clone_if_not_exists \
    "https://huggingface.co/microsoft/Florence-2-base" \
    "$MODELS_DIR/LLM/Florence-2-base"

# Group: 4_SDXL Inpaint

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