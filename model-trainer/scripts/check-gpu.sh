#!/bin/bash

echo "=== GPU Status Check ==="
echo ""

if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ nvidia-smi not found - NVIDIA drivers not installed or GPU not available"
    exit 1
fi

echo "→ GPU Information:"
nvidia-smi --query-gpu=index,name,driver_version,memory.total --format=csv
echo ""

echo "→ Current GPU Usage:"
nvidia-smi --query-gpu=index,memory.used,memory.total,utilization.gpu,temperature.gpu --format=csv
echo ""

echo "→ Detailed GPU Status:"
nvidia-smi
echo ""

# Check CUDA availability in Python
echo "→ Checking PyTorch CUDA:"
python3 -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}'); print(f'GPUs detected: {torch.cuda.device_count()}'); [print(f'  GPU {i}: {torch.cuda.get_device_name(i)}') for i in range(torch.cuda.device_count())]" 2>/dev/null || echo "PyTorch not installed or Python not available"

echo ""
echo "=== GPU Check Complete ==="
