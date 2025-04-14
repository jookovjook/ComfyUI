#!/bin/bash

# # 1) Install Git and any needed basics
# apt-get update && apt-get install -y git

# Set PROJECT_DIR environment variable if not already set
if [ -z "${PROJECT_DIR}" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PROJECT_DIR="~/dev/SD/ComfyUI"
    else
        PROJECT_DIR="/workspace/ComfyUI"
    fi
fi

# 4) Install dependencies
cd "$PROJECT_DIR"
# pip install -r requirements.txt

# # 5) Clone ComfyUI extensions
# # Function to extract repo name from git URL
# get_repo_name() {
#     local git_url=$1
#     # Remove .git extension and get the last part of the URL
#     echo "$git_url" | sed 's/\.git$//' | awk -F'/' '{print $NF}'
# }

# Function to clone and checkout a specific commit of a ComfyUI extension
clone_comfy_extension() {
    local repo_url=$1
    local commit_hash=$2
    local target_dir=${3:-$(get_repo_name "$repo_url")}

    cd "$PROJECT_DIR"
    git clone "$repo_url" "custom_nodes/$target_dir"
    cd "custom_nodes/$target_dir"
    git checkout -q "$commit_hash"

}

# !!! Fix macbook trackpad !!!
clone_comfy_extension \
    "https://github.com/subtleGradient/TinkerBot-tech-for-ComfyUI-Touchpad" \
    "a150a82ce8448de7b29bb759a3605ea8170856dc"

# Clone and checkout ComfyUI extensions
clone_comfy_extension \
    "https://github.com/yolain/ComfyUI-Easy-Use" \
    "be8306b17ad96aa7326bcc8012cc7c3489a94ab5"

clone_comfy_extension \
    "https://github.com/cubiq/ComfyUI_essentials" \
    "33ff89fd354d8ec3ab6affb605a79a931b445d99"

clone_comfy_extension \
    "https://github.com/kijai/ComfyUI-KJNodes" \
    "31cb7c1d14f86881ad34654a250d5e7682430fee"

clone_comfy_extension \
    "https://github.com/chflame163/ComfyUI_LayerStyle" \
    "f8439eb17f03e0fa60a35303493bfc9a7d5ab098"

clone_comfy_extension \
    "https://github.com/Fannovel16/comfyui_controlnet_aux" \
    "5a049bde9cc117dafc327cded156459289097ea1"

clone_comfy_extension \
    "https://github.com/kijai/ComfyUI-Florence2" \
    "47b554708ecbd611325cb87f96f56d3c3e41c19f"

clone_comfy_extension \
    "https://github.com/rgthree/rgthree-comfy" \
    "5d771b8b56a343c24a26e8cea1f0c87c3d58102f"

clone_comfy_extension \
    "https://github.com/WASasquatch/was-node-suite-comfyui" \
    "056badacda52e88d29d6a65f9509cd3115ace0f2"

clone_comfy_extension \
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack" \
    "7330577a0f53b01e0055b2d31708df423a08ef08"

clone_comfy_extension \
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes" \
    "d78b780ae43fcf8c6b7c6505e6ffb4584281ceca"

clone_comfy_extension \
    "https://github.com/chrisgoringe/cg-use-everywhere" \
    "ce510b97d10e69d5fd0042e115ecd946890d2079"

clone_comfy_extension \
    "https://github.com/BadCafeCode/masquerade-nodes-comfyui" \
    "432cb4d146a391b387a0cd25ace824328b5b61cf"

clone_comfy_extension \
    "https://github.com/jamesWalker55/comfyui-various" \
    "36454f91606bbff4fc36d90234981ca4a47e2695"

clone_comfy_extension \
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus" \
    "b188a6cb39b512a9c6da7235b880af42c78ccd0d"

clone_comfy_extension \
    "https://github.com/chflame163/ComfyUI_LayerStyle_Advance" \
    "4991451b73c7f7030114ecce67f31d75aee8a155"

clone_comfy_extension \
    "https://github.com/shadowcz007/comfyui-mixlab-nodes" \
    "67c974c96e6472316cb4bf4326281d9f86a25ae6"

clone_comfy_extension \
    "https://github.com/digitaljohn/comfyui-propost" \
    "df6a6d122498f57ad7195d58e07701a501c9dcb6"

clone_comfy_extension \
    "https://github.com/sipherxyz/comfyui-art-venture" \
    "50abaace756b96f5f5dc2c9d72826ef371afd45e"

# Download models
cd "$PROJECT_DIR"
echo "Running models.sh to download models..."
bash models.sh