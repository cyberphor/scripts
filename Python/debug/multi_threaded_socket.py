from socket import socket, AF_INET, SOCK_STREAM
from threading import Thread, current_thread

class Server:
    def __init__(self):
        self.ip = "127.0.0.1"
        self.port = 80
        self.address = (str(self.ip), self.port)
        self.threads = {}

    def handler(self, agent_socket, agent_port):
        while True:
            try:
                agent_request = agent_socket.recv(1024).decode()
            except ConnectionError:
                print(f"[FOXDIE: {agent_port}] disconnected")
                del self.threads[agent_port]
                break
            else:
                if agent_request:
                    print(agent_request)
                    agent_socket.send("OK".encode())

    def dispatch(self):
        with socket(AF_INET, SOCK_STREAM) as listener:
            listener.bind(self.address)
            listener.listen(5)
            while True:
                    agent_socket, agent_address = listener.accept()
                    agent_port = agent_address[1]
                    thread = Thread(
                        name = agent_port,
                        target = self.handler,
                        args = [agent_socket, agent_port]
                    )
                    self.threads[agent_port] = thread

    def spider(self):
        while True:
            for thread in list(self.threads.values()):
                if not thread.is_alive():
                    thread.start()

    def start(self):
        a = Thread(name = "Dispatch", target = self.dispatch)
        a.start()

        b = Thread(name = "Spider", target = self.spider)
        b.start()

if __name__ == "__main__":
    server = Server()
    server.start()
