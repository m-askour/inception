start_server()
      │
      ▼
  socket → bind → listen
      │
      ▼
  peek with select(timeout=0)
      │
      ├── 1 client knocking ──→  single client mode → snd_recv()
      │                                │
      │                          client done → loop back
      │
      └── 2+ clients knocking ──→  multiple client mode → connect_multiple_client()



      