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
            CsvConfiguration config2 = new CsvConfiguration();
            config2.Delimiter = ',';

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

                using (CsvWriter writer = new CsvWriter(new StreamWriter("benchmark-twoa-combined.txt"), config2))
                {
                    var records = benchmarks
                        .GroupBy(n => n.W)
                        .Where(n => n.Count() == 3)
                        .Select(n => new BenchmarkCombined(n.Skip(0).First(), n.Skip(1).First(), n.Skip(2).First()))
                        .OrderBy(n => n.V)
                        .ToList();

                    writer.WriteRecords(records);
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

    public class BenchmarkCombined
    {
        public string W { get; set; }

        public int R { get; set; }

        public long S { get; set; }

        public int H { get; set; }

        public long V { get; set; }

        public long E { get; set; }

        public string TA { get; set; }

        public long CA { get; set; }

        public string TB { get; set; }

        public long CB { get; set; }

        public string TC { get; set; }

        public long CC { get; set; }

        public BenchmarkCombined(Benchmark b1, Benchmark b2, Benchmark b3)
        {
            this.W = b1.W;
            this.R = b1.R;
            this.S = b1.S;
            this.H = b1.H;
            this.V = b1.V;
            this.E = b1.E;
            this.TA = b1.T;
            this.CA = b1.C;
            this.TB = b2.T;
            this.CB = b2.C;
            this.TC = b3.T;
            this.CC = b3.C;
        }
    }
}