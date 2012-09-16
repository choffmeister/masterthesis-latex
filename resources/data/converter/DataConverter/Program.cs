using System.Collections.Generic;
using System.IO;
using System.Linq;
using CsvHelper;
using CsvHelper.Configuration;

namespace DataConverter
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            CsvConfiguration config = new CsvConfiguration();
            config.Delimiter = ',';

            using (CsvReader reader = new CsvReader(new StreamReader("benchmark.txt"), config))
            {
                List<Benchmark> benchmarks = reader.GetRecords<Benchmark>().ToList();

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa1.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 1).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa2.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 2).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa3.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 3).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa1-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 1 && n.W.Contains("A_")).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa2-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 2 && n.W.Contains("A_")).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa3-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 3 && n.W.Contains("A_")).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa1-not-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 1 && !n.W.Contains("A_")).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa2-not-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 2 && !n.W.Contains("A_")).OrderBy(n => n.V));
                }

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa3-not-a.txt"), config))
                {
                    writer.WriteRecords(benchmarks.Where(n => n.A == 3 && !n.W.Contains("A_")).OrderBy(n => n.V));
                }
            }
        }
    }

    public class Benchmark
    {
        public int A { get; set; }

        public string W { get; set; }

        public int R { get; set; }

        public long S { get; set; }

        public string T { get; set; }

        public int H { get; set; }

        public long V { get; set; }

        public long E { get; set; }

        public long C { get; set; }
    }
}