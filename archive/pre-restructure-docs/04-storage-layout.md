# AI Data Mount

The 500 GB Ubuntu VM disk should be mounted as:

```text
/srv/ai
```

Important:

`/srv/ai` is not a home partition.

It is a service/application data mount point.

Expected layout:

```text
/srv/ai/
├── docker/
├── ollama/
├── open-webui/
├── qdrant/
├── neo4j/
├── jupyter/
├── ingest/
├── rag/
├── zotero/
├── backups/
└── models/
```

---
