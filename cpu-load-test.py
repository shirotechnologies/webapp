import multiprocessing
import time

def cpu_load():
    """ Function to generate high CPU load """
    while True:
        pass  # Infinite loop to keep the CPU busy

if __name__ == "__main__":
    # Define the number of CPU cores to stress and the duration
    num_cores = multiprocessing.cpu_count()  # Number of CPU cores
    duration = 300  # Duration in seconds (e.g., 5 minutes)

    # Create a pool of processes to stress each core
    processes = []
    for _ in range(num_cores):
        p = multiprocessing.Process(target=cpu_load)
        p.start()
        processes.append(p)

    print(f"Simulating CPU load on {num_cores} cores for {duration} seconds.")
    
    # Wait for the duration
    time.sleep(duration)

    # Terminate all processes after the duration
    for p in processes:
        p.terminate()
        p.join()

    print("CPU load test completed.")
