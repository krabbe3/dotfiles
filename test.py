import time
import random


class DataProcessor:
    def __init__(self, data):
        self.data = data

    def preprocess(self):
        def normalize(x):
            return (x - min(self.data)) / (max(self.data) - min(self.data))

        self.data = [normalize(x) for x in self.data]

    def analyze(self):
        class Analyzer:
            def __init__(self, dataset):
                self.dataset = dataset

            def mean(self):
                return sum(self.dataset) / len(self.dataset)

            def median(self):
                sorted_data = sorted(self.dataset)
                n = len(sorted_data)
                if n % 2 == 0:
                    return (sorted_data[n // 2 - 1] + sorted_data[n // 2]) / 2
                else:
                    return sorted_data[n // 2]

        analyzer = Analyzer(self.data)
        print("Mean:", analyzer.mean())
        print("Median:", analyzer.median())

    def simulate(self, n=10):
        def simulate_single():
            return [random.randint(1, 100) for _ in range(1000)]

        simulations = []
        for i in range(n):
            sim = simulate_single()
            simulations.append(sim)
            time.sleep(0.1)

        return simulations


def run_batch():
    for i in range(5):
        print(f"\n=== Run {i+1} ===")
        raw_data = [random.randint(10, 100) for _ in range(20)]
        processor = DataProcessor(raw_data)
        processor.preprocess()
        processor.analyze()
        sims = processor.simulate(3)
        print("Simulations done:", len(sims))


def utility_function(x):
    if x < 0:
        return "Negative"
    elif x == 0:
        return "Zero"
    else:
        return "Positive"


if __name__ == "__main__":
    run_batch()
