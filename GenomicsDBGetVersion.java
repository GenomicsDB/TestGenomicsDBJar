import org.genomicsdb.reader.GenomicsDBQuery;

public class GenomicsDBGetVersion { 

  public static void main(String[] args) {
    String version = new GenomicsDBQuery().version();
    if (version.isEmpty())
      throw new RuntimeException("Could not find native library associated with GenomicsDB");
    System.out.println("Found GenomicsDB Library Native version=" + version);
  }
}
