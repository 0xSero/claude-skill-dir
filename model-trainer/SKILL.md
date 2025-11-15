# LLM Training Expert (LoRA/QLoRA)

Expert in training and fine-tuning Large Language Models using LoRA (Low-Rank Adaptation) and QLoRA (Quantized LoRA). Specializes in efficient training workflows with UV package manager, GPU management, dataset preparation, hyperparameter optimization, and training monitoring.

## When to use this skill

- Fine-tuning LLMs with LoRA or QLoRA
- Setting up training environments for machine learning
- Preparing datasets for LLM training
- Monitoring GPU usage and training progress
- Optimizing training hyperparameters
- Managing multiple training experiments
- Resuming interrupted training sessions
- Evaluating fine-tuned models
- Deploying trained models
- Converting between model formats

## Core Expertise

### Environment Setup with UV

#### Quick Start
```bash
# Create training project with UV
uv init llm-training
cd llm-training
uv venv

# Install core dependencies
uv add torch torchvision torchaudio --index https://download.pytorch.org/whl/cu118
uv add transformers datasets peft accelerate bitsandbytes
uv add wandb tensorboard
uv add --dev jupyter ipykernel
```

#### Essential Libraries
- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face transformers library
- **PEFT** - Parameter-Efficient Fine-Tuning (LoRA implementation)
- **Accelerate** - Distributed training and mixed precision
- **bitsandbytes** - Quantization for QLoRA
- **Datasets** - Hugging Face datasets library
- **Wandb/TensorBoard** - Experiment tracking
- **Flash-Attention-2** - Optimized attention mechanism (optional)

### GPU Management

#### Check GPU Status
```bash
# Check NVIDIA GPU status
nvidia-smi

# Continuous monitoring (refresh every 1 second)
watch -n 1 nvidia-smi

# Detailed GPU info
nvidia-smi -q

# GPU utilization logging
nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv -l 1 > gpu_log.csv
```

#### GPU Selection
```python
import torch
import os

# Check available GPUs
print(f"GPUs available: {torch.cuda.device_count()}")
print(f"Current GPU: {torch.cuda.current_device()}")
print(f"GPU name: {torch.cuda.get_device_name(0)}")

# Set specific GPU
os.environ["CUDA_VISIBLE_DEVICES"] = "0"  # Use first GPU only

# Check memory
print(f"GPU memory allocated: {torch.cuda.memory_allocated() / 1e9:.2f} GB")
print(f"GPU memory reserved: {torch.cuda.memory_reserved() / 1e9:.2f} GB")
```

### LoRA Training

#### Basic LoRA Configuration
```python
from peft import LoraConfig, get_peft_model, TaskType

# LoRA configuration
lora_config = LoraConfig(
    r=16,                          # Rank - lower = more compression, less capacity
    lora_alpha=32,                 # Scaling factor (typically 2x rank)
    target_modules=[               # Which modules to apply LoRA to
        "q_proj",
        "k_proj",
        "v_proj",
        "o_proj",
        "gate_proj",
        "up_proj",
        "down_proj",
    ],
    lora_dropout=0.05,            # Dropout for LoRA layers
    bias="none",                   # Bias training: 'none', 'all', or 'lora_only'
    task_type=TaskType.CAUSAL_LM, # Task type
)

# Apply LoRA to model
from transformers import AutoModelForCausalLM
base_model = AutoModelForCausalLM.from_pretrained("model-name")
model = get_peft_model(base_model, lora_config)

# Print trainable parameters
model.print_trainable_parameters()
# Output: trainable params: 4,194,304 || all params: 6,742,609,920 || trainable%: 0.0622
```

### QLoRA Training

#### QLoRA Setup (4-bit Quantization)
```python
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
from peft import prepare_model_for_kbit_training
import torch

# 4-bit quantization config
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,                      # Enable 4-bit loading
    bnb_4bit_quant_type="nf4",             # Quantization type (nf4 or fp4)
    bnb_4bit_compute_dtype=torch.bfloat16, # Compute dtype for 4-bit
    bnb_4bit_use_double_quant=True,        # Nested quantization
)

# Load model with quantization
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    quantization_config=bnb_config,
    device_map="auto",                      # Automatic device placement
    trust_remote_code=True,
)

# Prepare for k-bit training
model = prepare_model_for_kbit_training(model)

# Add LoRA adapters
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=64,
    lora_alpha=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM",
)

model = get_peft_model(model, lora_config)
```

### Dataset Preparation

#### Loading and Preparing Data
```python
from datasets import load_dataset

# Load from Hugging Face Hub
dataset = load_dataset("dataset-name")

# Load from local files
dataset = load_dataset("json", data_files="data.jsonl")
dataset = load_dataset("csv", data_files="data.csv")

# Custom dataset
from datasets import Dataset
data = {
    "text": ["example 1", "example 2", ...],
    "labels": [0, 1, ...]
}
dataset = Dataset.from_dict(data)

# Preprocessing
def preprocess_function(examples):
    return tokenizer(
        examples["text"],
        truncation=True,
        max_length=512,
        padding="max_length",
    )

tokenized_dataset = dataset.map(
    preprocess_function,
    batched=True,
    remove_columns=dataset.column_names,
)

# Train/test split
split_dataset = dataset.train_test_split(test_size=0.1)
```

#### Instruction Tuning Format
```python
# Alpaca-style instruction format
def format_instruction(sample):
    return f"""Below is an instruction that describes a task. Write a response that appropriately completes the request.

### Instruction:
{sample['instruction']}

### Response:
{sample['output']}"""

# ChatML format
def format_chatML(sample):
    return f"""<|im_start|>system
{sample['system']}<|im_end|>
<|im_start|>user
{sample['user']}<|im_end|>
<|im_start|>assistant
{sample['assistant']}<|im_end|>"""
```

### Training Configuration

#### Complete Training Script
```python
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling,
)
from peft import LoraConfig, get_peft_model
import torch

# Load model and tokenizer
model_name = "meta-llama/Llama-2-7b-hf"
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.bfloat16,
    device_map="auto",
)

# Apply LoRA
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)
model = get_peft_model(model, lora_config)

# Training arguments
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    per_device_eval_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    warmup_steps=100,
    logging_steps=10,
    save_steps=100,
    eval_steps=100,
    evaluation_strategy="steps",
    save_total_limit=3,
    load_best_model_at_end=True,
    report_to="wandb",              # or "tensorboard"
    fp16=False,
    bf16=True,                      # Use bfloat16 if available
    optim="paged_adamw_8bit",       # Memory-efficient optimizer
    max_grad_norm=0.3,
    lr_scheduler_type="cosine",
)

# Data collator
data_collator = DataCollatorForLanguageModeling(
    tokenizer=tokenizer,
    mlm=False,
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    data_collator=data_collator,
)

# Train
trainer.train()

# Save model
trainer.save_model("./final_model")
```

### Hyperparameter Optimization

#### Key Hyperparameters
- **Learning Rate**: 1e-4 to 5e-4 (typically 2e-4 for LoRA)
- **LoRA Rank (r)**: 8, 16, 32, 64 (higher = more capacity, more memory)
- **LoRA Alpha**: Typically 2x the rank
- **Batch Size**: Depends on GPU memory (1-8 per device)
- **Gradient Accumulation**: Multiply to get effective batch size
- **Epochs**: 1-5 (more can lead to overfitting)
- **Warmup Steps**: 5-10% of total steps
- **Max Length**: 512, 1024, 2048 (longer = more memory)

#### Finding Optimal Batch Size
```python
# Start with batch size 1 and increase until OOM
def find_max_batch_size(model, tokenizer, dataset):
    batch_size = 1
    while True:
        try:
            print(f"Trying batch size: {batch_size}")
            # Try training step
            # If successful, increase
            batch_size *= 2
        except RuntimeError as e:
            if "out of memory" in str(e):
                print(f"Max batch size: {batch_size // 2}")
                return batch_size // 2
            raise e
```

### Experiment Tracking

#### Weights & Biases
```python
import wandb

# Initialize
wandb.init(
    project="llm-finetuning",
    name="llama2-7b-lora",
    config={
        "learning_rate": 2e-4,
        "epochs": 3,
        "batch_size": 4,
        "lora_r": 16,
    }
)

# Training with wandb (automatic with report_to="wandb")
# Manual logging
wandb.log({"train_loss": loss, "epoch": epoch})
```

#### TensorBoard
```python
from torch.utils.tensorboard import SummaryWriter

writer = SummaryWriter('runs/experiment_1')

# Log metrics
writer.add_scalar('Loss/train', loss, step)
writer.add_scalar('Loss/val', val_loss, step)

# View in browser
# tensorboard --logdir=runs
```

### Resume Training

```python
# Resume from checkpoint
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
)

# Resume from last checkpoint
trainer.train(resume_from_checkpoint=True)

# Resume from specific checkpoint
trainer.train(resume_from_checkpoint="./results/checkpoint-1000")
```

### Model Evaluation

```python
# Evaluate on test set
eval_results = trainer.evaluate()
print(f"Perplexity: {torch.exp(torch.tensor(eval_results['eval_loss'])):.2f}")

# Generate text
from transformers import pipeline

generator = pipeline("text-generation", model=model, tokenizer=tokenizer)
output = generator("Your prompt here", max_length=100)
print(output[0]['generated_text'])
```

### Model Saving and Loading

```python
# Save LoRA adapter only (small file ~10-100MB)
model.save_pretrained("./lora-adapter")
tokenizer.save_pretrained("./lora-adapter")

# Load LoRA adapter
from peft import PeftModel
base_model = AutoModelForCausalLM.from_pretrained("base-model-name")
model = PeftModel.from_pretrained(base_model, "./lora-adapter")

# Merge LoRA weights with base model
merged_model = model.merge_and_unload()
merged_model.save_pretrained("./merged-model")

# Push to Hugging Face Hub
model.push_to_hub("username/model-name")
tokenizer.push_to_hub("username/model-name")
```

### Memory Optimization

#### Gradient Checkpointing
```python
model.gradient_checkpointing_enable()
```

#### Flash Attention 2
```python
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    use_flash_attention_2=True,  # Requires flash-attn package
    torch_dtype=torch.bfloat16,
)
```

#### Mixed Precision Training
```python
training_args = TrainingArguments(
    ...
    fp16=False,
    bf16=True,  # Better for training stability
)
```

### Common Training Issues

#### Out of Memory (OOM)
- Reduce batch size
- Enable gradient checkpointing
- Use gradient accumulation
- Reduce max sequence length
- Use QLoRA instead of LoRA
- Use smaller LoRA rank

#### Slow Training
- Increase batch size (if memory allows)
- Use Flash Attention 2
- Use faster data loading (increase num_workers)
- Use mixed precision (bf16/fp16)
- Optimize data preprocessing

#### Poor Results
- Increase LoRA rank
- Increase training epochs
- Adjust learning rate
- Check dataset quality
- Verify target modules are correct
- Try different prompt formats

## Project Structure

```
llm-training/
├── pyproject.toml
├── .env
├── data/
│   ├── train.jsonl
│   └── val.jsonl
├── configs/
│   ├── lora_config.py
│   └── training_args.py
├── src/
│   ├── data_prep.py
│   ├── train.py
│   └── evaluate.py
├── scripts/
│   ├── prepare_data.sh
│   └── train_model.sh
├── checkpoints/
│   └── checkpoint-*/
├── results/
│   └── final_model/
└── logs/
    ├── wandb/
    └── tensorboard/
```

## Resources

The `resources/` directory contains:
- Example training configurations
- Dataset templates
- Prompt format examples
- Model cards templates
- Hyperparameter tuning guides

## Scripts

The `scripts/` directory contains:
- `setup-training-env.sh` - Setup training environment with UV
- `check-gpu.sh` - Check GPU availability and status
- `train-lora.py` - LoRA training script
- `train-qlora.py` - QLoRA training script
- `merge-adapter.py` - Merge LoRA with base model
- `monitor-training.sh` - Monitor GPU and training progress

## Hooks

The `hooks/` directory contains:
- Training start hooks (GPU check, disk space check)
- Training monitoring hooks
- Checkpoint backup hooks

## Agents

The `agents/` directory contains:
- `data-preprocessor` - Prepare and validate datasets
- `hyperparameter-tuner` - Optimize hyperparameters
- `training-monitor` - Monitor and alert on training issues
- `model-evaluator` - Comprehensive model evaluation

## Quick Start Checklist

- [ ] Check GPU availability (`nvidia-smi`)
- [ ] Create virtual environment with UV
- [ ] Install dependencies (torch, transformers, peft, etc.)
- [ ] Prepare and validate dataset
- [ ] Configure LoRA/QLoRA parameters
- [ ] Set up experiment tracking (wandb/tensorboard)
- [ ] Run small test training (1-2 steps)
- [ ] Start full training
- [ ] Monitor GPU usage and training metrics
- [ ] Evaluate model on validation set
- [ ] Save and version control adapters
- [ ] Document training configuration

## Integration with Other Skills

- Works with `/python-dev/` for environment management
- Integrates with `/system-manager/` for experiment documentation
- Complements `/automater/` for training automation
- Supports `/data-reporter/` for tracking training sessions

## Best Practices

1. **Always start with a small dataset** to verify setup
2. **Monitor GPU memory** throughout training
3. **Use experiment tracking** (wandb/tensorboard) from day 1
4. **Save checkpoints frequently** to resume if interrupted
5. **Version control your configs** not your models
6. **Document hyperparameters** for reproducibility
7. **Test on validation set** before full training
8. **Use bfloat16** when available (better than fp16)
9. **Start with QLoRA** if memory constrained
10. **Keep base models cached** to avoid re-downloading

## Notes

- QLoRA can train 65B models on a single 24GB GPU
- LoRA adapters are typically 10-100MB (vs 10-100GB for full models)
- Training time varies: 7B model ~1-2 hours on A100 for 1 epoch
- Always validate your data format before long training runs
- Use gradient accumulation to simulate larger batch sizes
- Monitor training loss - should decrease steadily
- Validation loss plateau indicates convergence or overfitting
