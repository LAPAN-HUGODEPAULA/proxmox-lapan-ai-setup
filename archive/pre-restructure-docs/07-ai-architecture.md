
# AI Models

## Initial Ollama Models

```bash
ollama pull qwen3:8b
ollama pull qwen2.5-coder:7b
ollama pull bge-m3
ollama pull embeddinggemma
```

---

# Planned AI Architecture

## Components

### Vector Database

```text
Qdrant
```

### Graph Database

```text
Neo4j
```

### LLM Runtime

```text
Ollama
```

### Interface

```text
Open WebUI
```

### Notebook Environment

```text
JupyterLab
```

---

# Planned Retrieval Architecture

## Retrieval Pipeline

```text
Documents
    ↓
Parsing
    ↓
Chunking
    ↓
Embeddings
    ↓
Qdrant
    ↓
Hybrid retrieval
    ↓
Neo4j semantic expansion
    ↓
Ollama synthesis
```

---

# Planned Scientific Workflow

## Primary Use Cases

- coding assistance
- scientific paper summarization
- semantic graph extraction
- taxonomy generation
- local agents
- clinical drafting support

---
