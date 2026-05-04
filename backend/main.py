from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Standard CORS setup
app.add_middleware(
   CORSMiddleware,
   allow_origins=["*"],
   allow_credentials=True,
   allow_methods=["*"],
   allow_headers=["*"],
)

class ConnectionManager:
   def __init__(self):
       self.active_connections: list[WebSocket] = []
       # --- ADDED: Store the global state ---
       self.current_state = "OFF"

   async def connect(self, websocket: WebSocket):
       await websocket.accept()
       self.active_connections.append(websocket)
       # --- ADDED: Immediately tell the new client the current status ---
       await websocket.send_text(self.current_state)
       print(f"Device synced. Current state: {self.current_state}")

   def disconnect(self, websocket: WebSocket):
       if websocket in self.active_connections:
           self.active_connections.remove(websocket)

   async def broadcast(self, message: str):
       # --- ADDED: Update the saved state before broadcasting ---
       self.current_state = message
       for connection in self.active_connections:
           try:
               await connection.send_text(message)
           except Exception:
               pass

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
   await manager.connect(websocket)
   try:
       while True:
           data = await websocket.receive_text()
           print(f"Action from {client_id}: {data}")
           await manager.broadcast(data)
   except WebSocketDisconnect:
       manager.disconnect(websocket)
