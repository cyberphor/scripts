from threading import Thread, current_thread
from time import sleep

def main():
    while True:
        thread = Thread(target = handler)
        try:
            thread.start()
            while thread.is_alive():
                thread.join(0.5)
        except KeyboardInterrupt:
            thread.alive = False
            thread.join()
            break

def handler():
    thread = current_thread()
    thread.alive = True
    for i in range(6):
        if not thread.alive:
            print(f"[FOXDIE: {i}] died")
            break
        print(f"[FOXDIE: {i}] started")
        sleep(2)
        print(f"[FOXDIE: {i}] stopped")

if __name__ == "__main__":
	main()
